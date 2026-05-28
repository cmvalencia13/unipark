"use client";

import { useSession } from "next-auth/react";

export function Header() {
  const { data: session } = useSession();
  const user = session?.user;
  const role = (user as any)?.role as string;

  return (
    <header className="h-14 sticky top-0 z-30 bg-surface-container-lowest/80 backdrop-blur-xl border-b border-white/5 flex items-center justify-end px-6 ml-60">
      <div className="flex items-center gap-3">
        <div className="w-8 h-8 rounded-full bg-surface-container border border-white/10 flex items-center justify-center">
          <span className="material-symbols-outlined text-sm text-outline">person</span>
        </div>
        <div>
          <div className="text-on-background text-body-md font-medium leading-tight">{user?.name || user?.email}</div>
          <div className={`text-label-sm ${role === "superadmin" ? "text-secondary-fixed" : "text-outline"}`}>
            {role}
          </div>
        </div>
      </div>
    </header>
  );
}
