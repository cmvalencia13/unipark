"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useSession } from "next-auth/react";

const adminLinks = [
  { href: "/admin/dashboard", icon: "dashboard", label: "Dashboard" },
  { href: "/admin/lots", icon: "directions_car", label: "Lots" },
  { href: "/admin/violations", icon: "gavel", label: "Violations" },
];

const superadminLinks = [
  { href: "/admin/users", icon: "group", label: "Users & Roles" },
  { href: "/admin/audit", icon: "receipt_long", label: "Audit Log" },
  { href: "/admin/settings", icon: "settings", label: "Settings" },
];

export function Sidebar() {
  const pathname = usePathname();
  const { data: session } = useSession();
  const role = (session?.user as any)?.role as string;

  const isActive = (href: string) => pathname === href;

  return (
    <aside className="w-60 h-screen fixed left-0 top-0 bg-surface-container-lowest border-r border-white/5 flex flex-col py-4 px-3 z-40">
      <Link href="/admin/dashboard" className="font-sora text-lg font-bold text-primary-fixed-dim px-3 mb-7">
        UniPark
      </Link>

      <nav className="flex-1">
        <div className="text-outline text-label-sm uppercase tracking-wider px-3 mb-2">Main</div>
        {adminLinks.map((link) => (
          <Link
            key={link.href}
            href={link.href}
            className={`flex items-center gap-2.5 px-3 py-2 rounded-lg mb-0.5 text-body-md transition-all ${
              isActive(link.href)
                ? "bg-secondary-fixed/10 text-secondary-fixed"
                : "text-on-surface-variant hover:text-secondary-fixed-dim"
            }`}
          >
            <span className="material-symbols-outlined text-xl">{link.icon}</span>
            <span>{link.label}</span>
          </Link>
        ))}

        {role === "superadmin" && (
          <>
            <div className="text-outline text-label-sm uppercase tracking-wider px-3 mb-2 mt-6">Administration</div>
            {superadminLinks.map((link) => (
              <Link
                key={link.href}
                href={link.href}
                className={`flex items-center gap-2.5 px-3 py-2 rounded-lg mb-0.5 text-body-md transition-all ${
                  isActive(link.href)
                    ? "bg-secondary-fixed/10 text-secondary-fixed"
                    : "text-on-surface-variant hover:text-secondary-fixed-dim"
                }`}
              >
                <span className="material-symbols-outlined text-xl">{link.icon}</span>
                <span>{link.label}</span>
              </Link>
            ))}
          </>
        )}
      </nav>

      <div className="border-t border-white/5 pt-3">
        <Link
          href="/api/auth/signout"
          className="flex items-center gap-2.5 px-3 py-2 rounded-lg text-on-surface-variant hover:text-error transition-all"
        >
          <span className="material-symbols-outlined text-xl">logout</span>
          <span>Sign Out</span>
        </Link>
      </div>
    </aside>
  );
}
