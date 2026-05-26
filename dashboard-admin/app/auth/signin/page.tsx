'use client';

import { signIn } from 'next-auth/react';
import { useSearchParams } from 'next/navigation';
import { Suspense } from 'react';

function SignInContent() {
  const searchParams = useSearchParams();
  const error = searchParams.get('error');

  return (
    <div className="flex items-center justify-center min-h-screen bg-gradient-to-br from-slate-950 via-slate-900 to-slate-950">
      <div className="w-full max-w-md">
        <div className="bg-slate-900 rounded-lg border border-slate-800 shadow-xl p-8">
          {/* Logo/Header */}
          <div className="text-center mb-8">
            <h1 className="text-3xl font-bold text-white mb-2">UniPark</h1>
            <p className="text-slate-400">Sistema de Gestión de Parqueaderos</p>
          </div>

          {/* Error Message */}
          {error && (
            <div className="mb-6 p-4 rounded-lg bg-red-500/10 border border-red-500/20 text-red-400 text-sm">
              Error en autenticación. Intenta nuevamente.
            </div>
          )}

          {/* Login Button */}
          <button
            onClick={() => signIn('keycloak', { callbackUrl: '/dashboard' })}
            className="w-full py-3 px-4 bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white font-semibold rounded-lg transition-all duration-200 shadow-lg hover:shadow-xl"
          >
            Iniciar Sesión con Keycloak
          </button>

          {/* Footer */}
          <p className="text-center text-slate-500 text-sm mt-6">
            Solo personal universitario autorizado
          </p>
        </div>

        {/* Support Info */}
        <div className="text-center mt-8 text-slate-400 text-sm">
          <p>¿Problemas? Contacta a</p>
          <p className="font-semibold text-slate-300">soporte@unipark.edu</p>
        </div>
      </div>
    </div>
  );
}

export default function SignInPage() {
  return (
    <Suspense fallback={
      <div className="flex items-center justify-center min-h-screen bg-slate-950">
        <div className="animate-pulse text-slate-400">Cargando...</div>
      </div>
    }>
      <SignInContent />
    </Suspense>
  );
}
