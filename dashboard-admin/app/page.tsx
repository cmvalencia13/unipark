'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useSession } from 'next-auth/react';

export default function Home() {
  const router = useRouter();
  const { data: session, status } = useSession();

  useEffect(() => {
    if (status === 'loading') return;

    if (session) {
      router.push('/dashboard');
    } else {
      router.push('/auth/signin');
    }
  }, [session, status, router]);

  return (
    <div className="flex items-center justify-center min-h-screen bg-slate-950">
      <div className="text-center">
        <div className="animate-spin inline-block">
          <div className="h-8 w-8 border-4 border-slate-600 border-t-blue-500 rounded-full"></div>
        </div>
        <p className="mt-4 text-slate-400">Cargando UniPark...</p>
      </div>
    </div>
  );
}
