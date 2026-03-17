import { cookies } from 'next/headers';
import { NextRequest, NextResponse } from 'next/server';

export async function POST(request: NextRequest) {
  const cookieStore = await cookies();
  cookieStore.delete('admin_token');
  
  // Redirect back to login
  const loginUrl = new URL('/login', request.url);
  return NextResponse.redirect(loginUrl);
}
