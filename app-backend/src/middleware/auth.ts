import { Response, NextFunction } from 'express';
import { auth } from '../config/firebase';
import { pool } from '../config/db';
import { AppError } from './errorHandler';
import { AuthenticatedRequest } from '../types';

export async function requireAuth(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction,
): Promise<void> {
  const header = req.headers.authorization;

  if (!header?.startsWith('Bearer ')) {
    res.status(401).json({ error: 'Missing or invalid Authorization header' });
    return;
  }

  const token = header.slice(7);
  const decoded = await auth.verifyIdToken(token).catch(() => {
    throw new AppError(401, 'Invalid or expired token');
  });

  // Ensure a users row exists — Firebase is the auth source of truth, but
  // foreign keys (orders.user_uid, addresses.user_uid, …) need the row.
  // Idempotent upsert avoids the "register endpoint" race + 23503 FK errors.
  await pool.query(
    `INSERT INTO users (uid, phone, email)
     VALUES ($1, $2, $3)
     ON CONFLICT (uid) DO NOTHING`,
    [decoded.uid, decoded.phone_number ?? '', decoded.email ?? null],
  );

  req.uid = decoded.uid;
  next();
}
