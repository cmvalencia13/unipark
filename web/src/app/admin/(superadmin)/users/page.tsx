"use client";

import { useState } from "react";
import useSWR from "swr";
import { GlassPanel } from "@/components/ui/GlassPanel";
import { StatusPill } from "@/components/ui/StatusPill";
import { StatusDot } from "@/components/ui/StatusDot";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { Toast, showToast } from "@/components/shared/Toast";
import { clientFetch } from "@/lib/api";

interface UserSummary {
  id: string;
  email: string;
  fullName: string;
  role: string;
  universityId: string;
  active: boolean;
  createdAt: string;
}

interface PageResponse<T> {
  content: T[];
  totalPages: number;
  totalElements: number;
  number: number;
}

const roleColor = (role: string) => {
  switch (role) {
    case "superadmin": return "green" as const;
    case "admin": return "cyan" as const;
    case "guard": return "purple" as const;
    default: return "gray" as const;
  }
};

const fetcher = (url: string) => clientFetch<PageResponse<UserSummary>>(url);

export default function UsersPage() {
  const [search, setSearch] = useState("");
  const [roleFilter, setRoleFilter] = useState("");
  const [page, setPage] = useState(0);
  const [editingUser, setEditingUser] = useState<UserSummary | null>(null);
  const [newRole, setNewRole] = useState("");
  const [confirmOpen, setConfirmOpen] = useState(false);

  const params = new URLSearchParams({ page: String(page), size: "20" });
  if (search) params.set("search", search);
  if (roleFilter) params.set("role", roleFilter);

  const { data, error, isLoading, mutate } = useSWR(`/v1/admin/users?${params}`, fetcher);

  const handleRoleChange = (user: UserSummary, role: string) => {
    setEditingUser(user);
    setNewRole(role);
    setConfirmOpen(true);
  };

  const confirmRoleChange = async () => {
    if (!editingUser) return;
    try {
      await clientFetch(`/v1/admin/users/${editingUser.id}`, {
        method: "PATCH",
        body: JSON.stringify({ role: newRole }),
      });
      mutate();
      showToast(`Changed ${editingUser.fullName}'s role to ${newRole}`, "success");
    } catch {
      showToast("Failed to update role", "error");
    }
    setConfirmOpen(false);
    setEditingUser(null);
  };

  return (
    <div>
      <h1 className="font-sora text-headline-lg text-on-background mb-6">Users & Roles</h1>

      <GlassPanel>
        <div className="flex gap-3 mb-4">
          <input
            type="text"
            placeholder="Search by name, email, or university ID..."
            value={search}
            onChange={(e) => { setSearch(e.target.value); setPage(0); }}
            className="flex-1 bg-surface-container border border-white/10 rounded-lg px-3 py-2 text-on-background text-body-md placeholder:text-outline focus:outline-none focus:border-secondary-fixed/50"
          />
          <select
            value={roleFilter}
            onChange={(e) => { setRoleFilter(e.target.value); setPage(0); }}
            className="bg-surface-container border border-white/10 rounded-lg px-3 py-2 text-on-background text-body-md focus:outline-none"
          >
            <option value="">All Roles</option>
            <option value="driver">Driver</option>
            <option value="guard">Guard</option>
            <option value="admin">Admin</option>
            <option value="superadmin">Superadmin</option>
          </select>
        </div>

        {isLoading && <div className="text-on-surface-variant py-8 text-center">Loading...</div>}
        {error && <div className="text-error py-8 text-center">Failed to load users</div>}

        {data && (
          <>
            <table className="w-full border-collapse">
              <thead>
                <tr className="border-b border-white/5">
                  <th className="text-left py-2 px-2 text-outline text-label-sm font-medium">User</th>
                  <th className="text-left py-2 px-2 text-outline text-label-sm font-medium">Email</th>
                  <th className="text-left py-2 px-2 text-outline text-label-sm font-medium">Role</th>
                  <th className="text-left py-2 px-2 text-outline text-label-sm font-medium">Status</th>
                </tr>
              </thead>
              <tbody>
                {data.content.map((user) => (
                  <tr key={user.id} className="border-b border-white/[0.02] hover:bg-surface-container/30 transition-colors">
                    <td className="py-2.5 px-2">
                      <div className="text-on-background text-body-md">{user.fullName}</div>
                      <div className="text-outline text-label-sm">{user.universityId}</div>
                    </td>
                    <td className="py-2.5 px-2 text-on-surface-variant text-body-md">{user.email}</td>
                    <td className="py-2.5 px-2">
                      <select
                        value={user.role}
                        onChange={(e) => handleRoleChange(user, e.target.value)}
                        className="bg-transparent border-none text-body-md cursor-pointer focus:outline-none"
                        style={{ color: "inherit" }}
                      >
                        <option value="driver">Driver</option>
                        <option value="guard">Guard</option>
                        <option value="admin">Admin</option>
                        <option value="superadmin">Superadmin</option>
                      </select>
                    </td>
                    <td className="py-2.5 px-2">
                      <StatusDot active={user.active} />
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>

            {data.totalPages > 1 && (
              <div className="flex justify-between items-center mt-4 pt-3 border-t border-white/5">
                <span className="text-outline text-label-sm">
                  {data.totalElements} users
                </span>
                <div className="flex gap-2">
                  <button
                    onClick={() => setPage(Math.max(0, page - 1))}
                    disabled={page === 0}
                    className="px-3 py-1 rounded text-body-md text-on-surface-variant hover:text-on-background disabled:opacity-30 transition-all"
                  >
                    Previous
                  </button>
                  <button
                    onClick={() => setPage(Math.min(data.totalPages - 1, page + 1))}
                    disabled={page >= data.totalPages - 1}
                    className="px-3 py-1 rounded text-body-md text-on-surface-variant hover:text-on-background disabled:opacity-30 transition-all"
                  >
                    Next
                  </button>
                </div>
              </div>
            )}
          </>
        )}
      </GlassPanel>

      <ConfirmDialog
        open={confirmOpen}
        title="Change User Role"
        message={`Set ${editingUser?.fullName}'s role to "${newRole}"?`}
        confirmLabel="Change Role"
        onConfirm={confirmRoleChange}
        onCancel={() => { setConfirmOpen(false); setEditingUser(null); }}
      />

      <Toast />
    </div>
  );
}
