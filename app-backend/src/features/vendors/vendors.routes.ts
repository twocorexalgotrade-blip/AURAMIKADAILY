import { Router, Request, Response } from 'express';
import { db } from '../../config/firebase';
import { AppError } from '../../middleware/errorHandler';

const router = Router();

// GET /vendors — list all verified vendors
router.get('/', async (_req: Request, res: Response) => {
  const snap = await db.collection('vendors')
    .where('isVerified', '==', true)
    .orderBy('name')
    .limit(50)
    .get();

  res.json({ vendors: snap.docs.map(d => ({ id: d.id, ...d.data() })) });
});

// GET /vendors/:id — single vendor
router.get('/:id', async (req: Request, res: Response) => {
  const snap = await db.collection('vendors').doc(req.params['id']!).get();
  if (!snap.exists) throw new AppError(404, 'Vendor not found');
  res.json({ id: snap.id, ...snap.data() });
});

// GET /vendors/:id/products — products from a specific vendor
router.get('/:id/products', async (req: Request, res: Response) => {
  const { limit = '20' } = req.query as Record<string, string>;
  const pageSize = Math.min(parseInt(limit, 10) || 20, 100);

  const snap = await db.collection('products')
    .where('vendorId', '==', req.params['id'])
    .orderBy('createdAt', 'desc')
    .limit(pageSize)
    .get();

  res.json({ products: snap.docs.map(d => ({ id: d.id, ...d.data() })) });
});

export default router;
