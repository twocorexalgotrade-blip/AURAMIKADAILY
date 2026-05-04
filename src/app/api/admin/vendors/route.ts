import { NextRequest, NextResponse } from 'next/server';
import { cookies } from 'next/headers';
import { Pool } from 'pg';
import bcrypt from 'bcryptjs';
import crypto from 'crypto';

const pool = new Pool({ connectionString: process.env.DATABASE_URL });

async function isAdmin(): Promise<boolean> {
  const cookieStore = await cookies();
  const token = cookieStore.get('admin_token');
  return !!(token && token.value === process.env.ADMIN_PASSWORD);
}

function generateUsername(vendorName: string): string {
  const slug = vendorName.toLowerCase().replace(/[^a-z0-9]/g, '').slice(0, 10);
  const suffix = crypto.randomBytes(3).toString('hex');
  return `vendor_${slug}_${suffix}`;
}

function generatePassword(): string {
  // 16-char alphanumeric password
  return crypto.randomBytes(12).toString('base64url').slice(0, 16);
}

export async function GET(_req: NextRequest) {
  if (!(await isAdmin())) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

  const result = await pool.query(`
    SELECT v.id, v.name, v.description, v.logo_url, v.is_verified, v.rating, v.created_at,
           vc.username, vc.last_login,
           (SELECT COUNT(*) FROM products WHERE vendor_id = v.id) AS product_count
    FROM vendors v
    LEFT JOIN vendor_credentials vc ON vc.vendor_id = v.id
    ORDER BY v.created_at DESC
  `);

  return NextResponse.json({ vendors: result.rows });
}

export async function POST(req: NextRequest) {
  if (!(await isAdmin())) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

  const body = await req.json() as { name?: string; description?: string; logo_url?: string };
  const { name, description, logo_url } = body;

  if (!name?.trim()) return NextResponse.json({ error: 'name is required' }, { status: 400 });

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    const vendorResult = await client.query(
      `INSERT INTO vendors (name, description, logo_url, is_verified)
       VALUES ($1, $2, $3, true) RETURNING id, name`,
      [name.trim(), description ?? null, logo_url ?? null],
    );
    const vendor = vendorResult.rows[0];

    const username = generateUsername(name);
    const plainPassword = generatePassword();
    const passwordHash = await bcrypt.hash(plainPassword, 12);

    await client.query(
      `INSERT INTO vendor_credentials (vendor_id, username, password_hash) VALUES ($1, $2, $3)`,
      [vendor.id, username, passwordHash],
    );

    await client.query('COMMIT');

    return NextResponse.json({
      vendor: { id: vendor.id, name: vendor.name },
      credentials: { username, password: plainPassword },
    }, { status: 201 });
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}
