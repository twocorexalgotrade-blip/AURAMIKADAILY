import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  // Check if we're accessing an admin route
  if (request.nextUrl.pathname.startsWith('/admin')) {
    const token = request.cookies.get('admin_token')?.value;
    
    // In production/dev, we check if the token matches the env password
    // A simple secure checking mechanism
    const adminPassword = process.env.ADMIN_PASSWORD;
    
    if (!adminPassword) {
      console.warn('ADMIN_PASSWORD not set in environment variables');
    }

    if (!token || token !== adminPassword) {
      // Redirect to login if not authenticated
      const loginUrl = new URL('/login', request.url);
      loginUrl.searchParams.set('callbackUrl', request.nextUrl.pathname);
      return NextResponse.redirect(loginUrl);
    }
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/admin/:path*'],
};
