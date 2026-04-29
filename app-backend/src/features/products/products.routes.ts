import { Router, Request, Response } from 'express';
import { db } from '../../config/firebase';
import { requireAuth } from '../../middleware/auth';
import { AppError } from '../../middleware/errorHandler';
import { AuthenticatedRequest } from '../../types';

const router = Router();

// GET /products — list products with optional filters
// Query: ?vibe=old_money&category=rings&limit=20&startAfter=<docId>
router.get('/', async (req: Request, res: Response) => {
  const { vibe, category, limit = '20', startAfter } = req.query as Record<string, string>;
  const pageSize = Math.min(parseInt(limit, 10) || 20, 100);

  let query = db.collection('products').orderBy('createdAt', 'desc').limit(pageSize) as
    FirebaseFirestore.Query;

  if (vibe) query = query.where('vibe', '==', vibe);
  if (category) query = query.where('category', '==', category);

  if (startAfter) {
    const cursor = await db.collection('products').doc(startAfter).get();
    if (cursor.exists) query = query.startAfter(cursor);
  }

  const snap = await query.get();
  const products = snap.docs.map(d => ({ id: d.id, ...d.data() }));

  res.json({ products, nextStartAfter: snap.docs.at(-1)?.id ?? null });
});

// GET /products/search?q=gold+ring
router.get('/search', async (req: Request, res: Response) => {
  const q = (req.query['q'] as string ?? '').toLowerCase().trim();
  if (!q) throw new AppError(400, 'Query param q is required');

  // Simple prefix search on productName — for full-text, integrate Algolia/Typesense
  const snap = await db.collection('products')
    .orderBy('productName')
    .startAt(q)
    .endAt(q + '')
    .limit(30)
    .get();

  res.json({ products: snap.docs.map(d => ({ id: d.id, ...d.data() })) });
});

// GET /products/:id — single product
router.get('/:id', async (req: Request, res: Response) => {
  const snap = await db.collection('products').doc(req.params['id']!).get();
  if (!snap.exists) throw new AppError(404, 'Product not found');
  res.json({ id: snap.id, ...snap.data() });
});

// POST /products/:id/wishlist — toggle wishlist
router.post('/:id/wishlist', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const { id } = req.params as { id: string };
  const userRef = db.collection('users').doc(req.uid);
  const snap = await userRef.get();
  const wishlist: string[] = snap.data()?.wishlist ?? [];
  const inWishlist = wishlist.includes(id);

  if (inWishlist) {
    await userRef.update({ wishlist: wishlist.filter(w => w !== id) });
    res.json({ wishlisted: false });
  } else {
    await userRef.update({ wishlist: [...wishlist, id] });
    res.json({ wishlisted: true });
  }
});

// GET /products/wishlist/mine — fetch wishlisted products
router.get('/wishlist/mine', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const snap = await db.collection('users').doc(req.uid).get();
  const wishlist: string[] = snap.data()?.wishlist ?? [];

  if (wishlist.length === 0) {
    res.json({ products: [] });
    return;
  }

  const productSnaps = await Promise.all(
    wishlist.map(pid => db.collection('products').doc(pid).get()),
  );
  const products = productSnaps
    .filter(s => s.exists)
    .map(s => ({ id: s.id, ...s.data() }));

  res.json({ products });
});

export default router;
