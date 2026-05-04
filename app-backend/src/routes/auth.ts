import { Router, Request, Response } from 'express';
import { z } from 'zod';
import { auth } from '../config/firebase';
import { pool } from '../config/db';
import { requireAuth } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';
import { AuthenticatedRequest } from '../types';

const router = Router();

const RegisterSchema = z.object({
  name: z.string().min(1),
  phone: z.string().min(10),
  email: z.string().email().optional(),
  dob: z.string().optional(),
});

const CheckPhoneSchema = z.object({
  phone: z.string().min(10),
});

// POST /auth/check-phone — public, no auth required.
// Lets the app verify whether a number is already registered BEFORE sending
// an OTP. Saves SMS cost and lets us route the user to the right screen.
// Normalises the phone input the same way the client stores it: keep digits
// only, take the last 10 (handles "+91 98…", "98765 43210", etc.).
router.post('/check-phone', async (req: Request, res: Response) => {
  const parsed = CheckPhoneSchema.safeParse(req.body);
  if (!parsed.success) throw new AppError(400, parsed.error.issues[0]?.message ?? 'Invalid body');

  const digits = parsed.data.phone.replace(/\D/g, '');
  const last10 = digits.length > 10 ? digits.slice(-10) : digits;

  // Match either the raw stored value, the +91-prefixed form, or the last-10
  // suffix. This keeps the check robust to historical phone formats in the
  // users table.
  const result = await pool.query(
    `SELECT 1 FROM users
     WHERE phone = $1 OR phone = $2 OR phone LIKE $3
     LIMIT 1`,
    [last10, `+91${last10}`, `%${last10}`],
  );
  res.json({ exists: result.rows.length > 0 });
});

// POST /auth/register
router.post('/register', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const parsed = RegisterSchema.safeParse(req.body);
  if (!parsed.success) throw new AppError(400, parsed.error.issues[0]?.message ?? 'Invalid body');

  const { name, phone, email, dob } = parsed.data;

  // requireAuth already inserted a stub row — promote it with the real
  // registration data instead of erroring on duplicate.
  const result = await pool.query(
    `INSERT INTO users (uid, name, phone, email, dob)
     VALUES ($1, $2, $3, $4, $5)
     ON CONFLICT (uid) DO UPDATE SET
       name  = COALESCE(NULLIF(EXCLUDED.name, ''),  users.name),
       phone = COALESCE(NULLIF(EXCLUDED.phone, ''), users.phone),
       email = COALESCE(EXCLUDED.email, users.email),
       dob   = COALESCE(EXCLUDED.dob,   users.dob),
       updated_at = NOW()
     RETURNING *, (xmax = 0) AS is_new_user`,
    [req.uid, name, phone, email ?? null, dob ?? null],
  );

  const row = result.rows[0];
  const isNewUser = row.is_new_user as boolean;
  delete row.is_new_user;
  res.status(isNewUser ? 201 : 200).json({ isNewUser, profile: row });
});

// DELETE /auth/account
//
// Order matters:
//   1. Revoke refresh tokens — invalidates any in-flight requests so the
//      requireAuth auto-create middleware can't silently restore the row.
//   2. Delete the Firebase Auth user — frees up the phone number for re-use.
//      If this fails, we abort BEFORE touching the DB so the user can retry.
//   3. Cascade-delete the DB row — addresses, cart, wishlist, orders all
//      drop via FK ON DELETE CASCADE. Gift cards keep owner_uid as NULL.
router.delete('/account', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const uid = req.uid;
  try {
    await auth.revokeRefreshTokens(uid);
  } catch (e) {
    console.error('[auth/delete] revokeRefreshTokens failed:', e);
    // Non-fatal — proceed; deleteUser below also implicitly invalidates tokens.
  }

  try {
    await auth.deleteUser(uid);
  } catch (e: unknown) {
    const code = (e as { code?: string }).code;
    // user-not-found means already deleted on Firebase side — proceed to DB cleanup.
    if (code !== 'auth/user-not-found') {
      console.error('[auth/delete] firebase deleteUser failed:', e);
      throw new AppError(502, 'Could not delete authentication record. Please try again.');
    }
  }

  await pool.query('DELETE FROM users WHERE uid = $1', [uid]);
  res.json({ deleted: true });
});

export default router;
