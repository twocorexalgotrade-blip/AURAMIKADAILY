import { Router, Response } from 'express';
import { z } from 'zod';
import admin from 'firebase-admin';
import { db, auth } from '../config/firebase';
import { requireAuth } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';
import { AuthenticatedRequest } from '../types';

const router = Router();

const RegisterSchema = z.object({
  name: z.string().min(1),
  phone: z.string().min(10),
  email: z.string().email().optional(),
});

// POST /auth/register — called after OTP verification to save profile
router.post('/register', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const parsed = RegisterSchema.safeParse(req.body);
  if (!parsed.success) throw new AppError(400, parsed.error.issues[0]?.message ?? 'Invalid body');

  const { name, phone, email } = parsed.data;
  const ref = db.collection('users').doc(req.uid);
  const snap = await ref.get();

  if (snap.exists) {
    res.json({ isNewUser: false, profile: snap.data() });
    return;
  }

  const profile = {
    uid: req.uid,
    name,
    phone,
    email: email ?? null,
    addresses: [],
    wishlist: [],
    isNewUser: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  await ref.set(profile);
  res.status(201).json({ isNewUser: true, profile });
});

// DELETE /auth/account — delete Firebase Auth user + Firestore user doc
router.delete('/account', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  await Promise.all([
    auth.deleteUser(req.uid),
    db.collection('users').doc(req.uid).delete(),
  ]);
  res.json({ deleted: true });
});

export default router;
