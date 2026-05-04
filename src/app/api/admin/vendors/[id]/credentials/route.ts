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

function generatePassword(): string {
  return crypto.randomBytes(12).toString('base64url').slice(0, 16);
}

// POST /api/admin/vendors/[id]/credentials — reset password for a vendor
export async function POST(_req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  if (!(await isAdmin())) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

  const { id } = await params;
  const newPassword = generatePassword();
  const passwordHash = await bcrypt.hash(newPassword, 12);

  const result = await pool.query(
    `UPDATE vendor_credentials SET password_hash = $1 WHERE vendor_id = $2 RETURNING username`,
    [passwordHash, id],
  );

  if (result.rows.length === 0) return NextResponse.json({ error: 'Vendor not found' }, { status: 404 });

  return NextResponse.json({ username: result.rows[0].username, password: newPassword });
}
