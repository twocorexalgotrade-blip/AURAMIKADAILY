import { Response, NextFunction } from 'express';
import { auth } from '../config/firebase';
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

  req.uid = decoded.uid;
  next();
}
