import { auth } from '@/lib/auth';
import { NextRequest, NextResponse } from 'next/server';

export async function middleware(request: NextRequest) {
  const session = await auth();
  const pathname = request.nextUrl.pathname;

  // Proteger rutas de dashboard
  if (pathname.startsWith('/dashboard')) {
    if (!session) {
      return NextResponse.redirect(new URL('/auth/signin', request.url));
    }
  }

  // Redirigir a dashboard si ya está autenticado y accede a signin
  if (pathname === '/auth/signin' && session) {
    return NextResponse.redirect(new URL('/dashboard', request.url));
  }

  // Redirigir raíz a dashboard si autenticado
  if (pathname === '/' && session) {
    return NextResponse.redirect(new URL('/dashboard', request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/dashboard/:path*', '/auth/signin', '/'],
};
