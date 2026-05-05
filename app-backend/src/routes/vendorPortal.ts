import { Router, Request, Response, NextFunction } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { z } from 'zod';
import { pool } from '../config/db';
import { env } from '../config/env';
import { AppError } from '../middleware/errorHandler';

const router = Router();

// ── S3 client (lazy – only used for presign endpoint) ──────────────────────
const s3 = new S3Client({
  region: env.aws.region,
  credentials: {
    accessKeyId: env.aws.accessKeyId,
    secretAccessKey: env.aws.secretAccessKey,
  },
});

// ── JWT helpers ────────────────────────────────────────────────────────────
interface VendorPayload {
  vendorId: string;
  username: string;
}

function signVendorToken(payload: VendorPayload): string {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  return jwt.sign(payload, env.vendor.jwtSecret, { expiresIn: '30d' } as any);
}

function verifyVendorToken(token: string): VendorPayload {
  return jwt.verify(token, env.vendor.jwtSecret) as VendorPayload;
}

// ── Auth middleware ────────────────────────────────────────────────────────
interface VendorRequest extends Request {
  vendorId?: string;
  vendorUsername?: string;
}

function requireVendorAuth(req: VendorRequest, _res: Response, next: NextFunction): void {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) throw new AppError(401, 'Missing vendor token');
  const token = header.slice(7);
  const payload = verifyVendorToken(token);
  req.vendorId = payload.vendorId;
  req.vendorUsername = payload.username;
  next();
}

// ── Schemas ────────────────────────────────────────────────────────────────
const LoginSchema = z.object({
  username: z.string().min(1),
  password: z.string().min(1),
});

const ProductSchema = z.object({
  product_name: z.string().min(1),
  brand_name: z.string().default(''),
  description: z.string().optional(),
  price: z.number().positive(),
  original_price: z.number().positive().optional(),
  category: z.string().optional(),
  vibe: z.string().optional(),
  material: z.string().optional(),
  image_urls: z.array(z.string()).default([]),
  is_express: z.boolean().default(false),
  in_stock: z.boolean().default(true),
  tags: z.array(z.string()).default([]),
});

const OrderStatusSchema = z.object({
  status: z.enum(['payment_pending', 'paid', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded']),
});

// ── POST /vendor/login ─────────────────────────────────────────────────────
router.post('/login', async (req: Request, res: Response) => {
  const parsed = LoginSchema.safeParse(req.body);
  if (!parsed.success) throw new AppError(400, parsed.error.issues[0]?.message ?? 'Invalid body');

  const { username, password } = parsed.data;

  const result = await pool.query(
    `SELECT vc.id, vc.vendor_id, vc.password_hash, v.name, v.description, v.logo_url, v.is_verified
     FROM vendor_credentials vc
     JOIN vendors v ON v.id = vc.vendor_id
     WHERE vc.username = $1`,
    [username],
  );

  if (result.rows.length === 0) throw new AppError(401, 'Invalid credentials');

  const row = result.rows[0];
  const valid = await bcrypt.compare(password, row.password_hash);
  if (!valid) throw new AppError(401, 'Invalid credentials');

  await pool.query(
    'UPDATE vendor_credentials SET last_login = NOW() WHERE id = $1',
    [row.id],
  );

  const token = signVendorToken({ vendorId: row.vendor_id, username });

  res.json({
    token,
    vendor: {
      id: row.vendor_id,
      name: row.name,
      description: row.description,
      logo_url: row.logo_url,
      is_verified: row.is_verified,
    },
  });
});

// ── GET /vendor/me ─────────────────────────────────────────────────────────
router.get('/me', requireVendorAuth, async (req: VendorRequest, res: Response) => {
  const result = await pool.query(
    `SELECT v.id, v.name, v.description, v.logo_url, v.banner_url, v.is_verified, v.rating,
            vc.username, vc.last_login
     FROM vendors v
     JOIN vendor_credentials vc ON vc.vendor_id = v.id
     WHERE v.id = $1 AND vc.username = $2`,
    [req.vendorId, req.vendorUsername],
  );
  if (result.rows.length === 0) throw new AppError(404, 'Vendor not found');
  res.json(result.rows[0]);
});

// ── PUT /vendor/me/logo ────────────────────────────────────────────────────
router.put('/me/logo', requireVendorAuth, async (req: VendorRequest, res: Response) => {
  const { logo_url } = req.body as { logo_url?: string };
  if (!logo_url || typeof logo_url !== 'string') {
    throw new AppError(400, 'logo_url is required');
  }
  await pool.query(
    'UPDATE vendors SET logo_url = $1 WHERE id = $2',
    [logo_url, req.vendorId],
  );
  res.json({ logo_url });
});

// ── PUT /vendor/me/banner ──────────────────────────────────────────────────
router.put('/me/banner', requireVendorAuth, async (req: VendorRequest, res: Response) => {
  const { banner_url } = req.body as { banner_url?: string };
  if (!banner_url || typeof banner_url !== 'string') {
    throw new AppError(400, 'banner_url is required');
  }
  await pool.query(
    'UPDATE vendors SET banner_url = $1 WHERE id = $2',
    [banner_url, req.vendorId],
  );
  res.json({ banner_url });
});

// ── GET /vendor/products ───────────────────────────────────────────────────
router.get('/products', requireVendorAuth, async (req: VendorRequest, res: Response) => {
  const limit = Math.min(parseInt((req.query['limit'] as string) || '50', 10), 100);
  const offset = parseInt((req.query['offset'] as string) || '0', 10);

  const result = await pool.query(
    `SELECT * FROM products WHERE vendor_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3`,
    [req.vendorId, limit, offset],
  );
  const count = await pool.query(
    'SELECT COUNT(*) FROM products WHERE vendor_id = $1',
    [req.vendorId],
  );
  res.json({ products: result.rows, total: parseInt(count.rows[0].count, 10) });
});

// ── POST /vendor/products ──────────────────────────────────────────────────
router.post('/products', requireVendorAuth, async (req: VendorRequest, res: Response) => {
  const parsed = ProductSchema.safeParse(req.body);
  if (!parsed.success) throw new AppError(400, parsed.error.issues[0]?.message ?? 'Invalid body');

  const d = parsed.data;
  const result = await pool.query(
    `INSERT INTO products
       (vendor_id, product_name, brand_name, description, price, original_price,
        category, vibe, material, image_urls, is_express, in_stock, tags)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)
     RETURNING *`,
    [req.vendorId, d.product_name, d.brand_name, d.description ?? null,
     d.price, d.original_price ?? null, d.category ?? null, d.vibe ?? null,
     d.material ?? null, d.image_urls, d.is_express, d.in_stock, d.tags],
  );
  res.status(201).json(result.rows[0]);
});

// ── PUT /vendor/products/:id ───────────────────────────────────────────────
router.put('/products/:id', requireVendorAuth, async (req: VendorRequest, res: Response) => {
  const parsed = ProductSchema.partial().safeParse(req.body);
  if (!parsed.success) throw new AppError(400, parsed.error.issues[0]?.message ?? 'Invalid body');

  // Verify ownership first
  const check = await pool.query(
    'SELECT id FROM products WHERE id = $1 AND vendor_id = $2',
    [req.params['id'], req.vendorId],
  );
  if (check.rows.length === 0) throw new AppError(404, 'Product not found');

  const d = parsed.data;
  const fields: string[] = [];
  const values: unknown[] = [];
  let i = 1;

  const allowed = ['product_name','brand_name','description','price','original_price',
                   'category','vibe','material','image_urls','is_express','in_stock','tags'] as const;

  for (const key of allowed) {
    if (key in d && d[key as keyof typeof d] !== undefined) {
      fields.push(`${key} = $${i++}`);
      values.push(d[key as keyof typeof d]);
    }
  }

  if (fields.length === 0) throw new AppError(400, 'No fields to update');

  fields.push(`updated_at = NOW()`);
  values.push(req.params['id'], req.vendorId);

  const result = await pool.query(
    `UPDATE products SET ${fields.join(', ')}
     WHERE id = $${i++} AND vendor_id = $${i} RETURNING *`,
    values,
  );
  res.json(result.rows[0]);
});

// ── DELETE /vendor/products/:id ────────────────────────────────────────────
router.delete('/products/:id', requireVendorAuth, async (req: VendorRequest, res: Response) => {
  const result = await pool.query(
    'DELETE FROM products WHERE id = $1 AND vendor_id = $2 RETURNING id',
    [req.params['id'], req.vendorId],
  );
  if (result.rows.length === 0) throw new AppError(404, 'Product not found');
  res.json({ deleted: true });
});

// ── GET /vendor/orders ─────────────────────────────────────────────────────
// Returns orders that contain at least one product belonging to this vendor.
router.get('/orders', requireVendorAuth, async (req: VendorRequest, res: Response) => {
  const limit = Math.min(parseInt((req.query['limit'] as string) || '50', 10), 100);
  const offset = parseInt((req.query['offset'] as string) || '0', 10);

  const result = await pool.query(
    `SELECT o.id, o.status, o.subtotal, o.total, o.is_express,
            o.cashfree_order_id, o.created_at, o.updated_at,
            o.address_name, o.address_phone, o.address_line1, o.address_city, o.address_pincode,
            json_agg(
              json_build_object(
                'id', oi.id,
                'product_id', oi.product_id,
                'product_name', oi.product_name,
                'brand_name', oi.brand_name,
                'price', oi.price,
                'quantity', oi.quantity,
                'image_url', oi.image_url
              )
            ) AS items
     FROM orders o
     JOIN order_items oi ON oi.order_id = o.id
     WHERE oi.product_id IN (SELECT id FROM products WHERE vendor_id = $1)
     GROUP BY o.id
     ORDER BY o.created_at DESC
     LIMIT $2 OFFSET $3`,
    [req.vendorId, limit, offset],
  );
  res.json({ orders: result.rows });
});

// ── PUT /vendor/orders/:orderId/status ─────────────────────────────────────
router.put('/orders/:orderId/status', requireVendorAuth, async (req: VendorRequest, res: Response) => {
  const parsed = OrderStatusSchema.safeParse(req.body);
  if (!parsed.success) throw new AppError(400, parsed.error.issues[0]?.message ?? 'Invalid status');

  // Confirm this vendor has items in the order
  const check = await pool.query(
    `SELECT 1 FROM order_items oi
     JOIN products p ON p.id = oi.product_id
     WHERE oi.order_id = $1 AND p.vendor_id = $2 LIMIT 1`,
    [req.params['orderId'], req.vendorId],
  );
  if (check.rows.length === 0) throw new AppError(404, 'Order not found');

  const result = await pool.query(
    `UPDATE orders SET status = $1, updated_at = NOW() WHERE id = $2 RETURNING id, status, updated_at`,
    [parsed.data.status, req.params['orderId']],
  );
  res.json(result.rows[0]);
});

// ── POST /vendor/images/presign ────────────────────────────────────────────
router.post('/images/presign', requireVendorAuth, async (req: VendorRequest, res: Response) => {
  if (!env.aws.s3Bucket) throw new AppError(500, 'S3 not configured');

  const { filename, contentType } = req.body as { filename?: string; contentType?: string };
  if (!filename || !contentType) throw new AppError(400, 'filename and contentType required');

  if (!contentType.startsWith('image/')) throw new AppError(400, 'Only image uploads allowed');

  const key = `vendor-products/${req.vendorId}/${Date.now()}-${filename.replace(/[^a-zA-Z0-9._-]/g, '_')}`;

  const command = new PutObjectCommand({
    Bucket: env.aws.s3Bucket,
    Key: key,
    ContentType: contentType,
  });

  const uploadUrl = await getSignedUrl(s3, command, { expiresIn: 300 });
  const publicUrl = `https://${env.aws.s3Bucket}.s3.${env.aws.region}.amazonaws.com/${key}`;

  res.json({ uploadUrl, publicUrl, key });
});

export default router;
