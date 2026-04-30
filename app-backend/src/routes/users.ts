import { Router, Response } from 'express';
import { z } from 'zod';
import admin from 'firebase-admin';
import { db } from '../config/firebase';
import { requireAuth } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';
import { AuthenticatedRequest } from '../types';

const router = Router();

const AddressSchema = z.object({
  name: z.string().min(1),
  phone: z.string().min(10),
  line1: z.string().min(1),
  city: z.string().min(1),
  pincode: z.string().length(6),
});

const ProfileUpdateSchema = z.object({
  name: z.string().min(1).optional(),
  email: z.string().email().optional(),
});

// GET /users/me
router.get('/me', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const snap = await db.collection('users').doc(req.uid).get();
  if (!snap.exists) throw new AppError(404, 'User not found');
  res.json(snap.data());
});

// PATCH /users/me
router.patch('/me', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const parsed = ProfileUpdateSchema.safeParse(req.body);
  if (!parsed.success) throw new AppError(400, parsed.error.issues[0]?.message ?? 'Invalid body');

  await db.collection('users').doc(req.uid).update({
    ...parsed.data,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  res.json({ updated: true });
});

// GET /users/me/addresses
router.get('/me/addresses', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const snap = await db.collection('users').doc(req.uid).get();
  res.json({ addresses: snap.data()?.addresses ?? [] });
});

// POST /users/me/addresses
router.post('/me/addresses', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const parsed = AddressSchema.safeParse(req.body);
  if (!parsed.success) throw new AppError(400, parsed.error.issues[0]?.message ?? 'Invalid body');

  await db.collection('users').doc(req.uid).update({
    addresses: admin.firestore.FieldValue.arrayUnion(parsed.data),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  res.status(201).json({ added: true });
});

// DELETE /users/me/addresses/:index
router.delete('/me/addresses/:index', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const idx = parseInt(req.params['index'] ?? '', 10);
  if (isNaN(idx) || idx < 0) throw new AppError(400, 'Invalid index');

  const snap = await db.collection('users').doc(req.uid).get();
  const addresses: unknown[] = snap.data()?.addresses ?? [];

  if (idx >= addresses.length) throw new AppError(404, 'Address not found');

  addresses.splice(idx, 1);
  await db.collection('users').doc(req.uid).update({
    addresses,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  res.json({ deleted: true });
});

export default router;
