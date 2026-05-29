"use client";

import { useState } from "react";
import useSWR from "swr";
import { GlassPanel } from "@/components/ui/GlassPanel";
import { StatusPill } from "@/components/ui/StatusPill";
import { Toast, showToast } from "@/components/shared/Toast";
import { clientFetch } from "@/lib/api";

interface ViolationSummary {
  id: string;
  vehiclePlate: string | null;
  guardName: string;
  lotName: string | null;
  reason: string;
  status: string;
  evidenceUrl: string | null;
  createdAt: string;
}

interface PageResponse<T> {
  content: T[];
  totalPages: number;
  totalElements: number;
  number: number;
}

const fetcher = (url: string) => clientFetch<PageResponse<ViolationSummary>>(url);

export default function ViolationsPage() {
  const [statusFilter, setStatusFilter] = useState("");
  const [page, setPage] = useState(0);
  const [selected, setSelected] = useState<ViolationSummary | null>(null);
  const [note, setNote] = useState("");

  const params = new URLSearchParams({ page: String(page), size: "20" });
  if (statusFilter) params.set("status", statusFilter);

  const { data, isLoading, mutate } = useSWR(`/v1/admin/violations?${params}`, fetcher);

  const resolveViolation = async (id: string, status: string) => {
    try {
      await clientFetch(`/v1/admin/violations/${id}`, {
        method: "PATCH",
        body: JSON.stringify({ status, resolutionNote: note }),
      });
      mutate();
      setSelected(null);
      setNote("");
      showToast(`Violation ${status.toLowerCase()}`, "success");
    } catch {
      showToast("Failed to resolve violation", "error");
    }
  };

  return (
    <div>
      <h1 className="font-sora text-headline-lg text-on-background mb-6">Violations</h1>

      <GlassPanel>
        <div className="flex gap-2 mb-4">
          {["", "PENDING", "APPROVED", "DISMISSED"].map((s) => (
            <button
              key={s}
              onClick={() => { setStatusFilter(s); setPage(0); }}
              className={`px-3 py-1.5 rounded-lg text-label-md transition-all ${
                statusFilter === s
                  ? "bg-secondary-fixed/10 text-secondary-fixed"
                  : "text-on-surface-variant hover:text-on-background"
              }`}
            >
              {s || "All"}
            </button>
          ))}
        </div>

        {isLoading && <div className="text-on-surface-variant py-8 text-center">Loading...</div>}

        {data && data.content.length === 0 && (
          <div className="text-on-surface-variant py-12 text-center">
            <span className="material-symbols-outlined text-4xl block mb-2">check_circle</span>
            No violations found
          </div>
        )}

        {data && data.content.length > 0 && (
          <table className="w-full border-collapse">
            <thead>
              <tr className="border-b border-white/5">
                <th className="text-left py-2 px-3 text-outline text-label-sm font-medium">Vehicle</th>
                <th className="text-left py-2 px-3 text-outline text-label-sm font-medium">Guard</th>
                <th className="text-left py-2 px-3 text-outline text-label-sm font-medium">Reason</th>
                <th className="text-left py-2 px-3 text-outline text-label-sm font-medium">Status</th>
                <th className="text-left py-2 px-3 text-outline text-label-sm font-medium">Date</th>
              </tr>
            </thead>
            <tbody>
              {data.content.map((v) => (
                <tr
                  key={v.id}
                  onClick={() => setSelected(v)}
                  className="border-b border-white/[0.02] hover:bg-surface-container/30 transition-colors cursor-pointer"
                >
                  <td className="py-2.5 px-3 text-on-background font-mono-data">{v.vehiclePlate || "—"}</td>
                  <td className="py-2.5 px-3 text-on-surface-variant text-body-md">{v.guardName}</td>
                  <td className="py-2.5 px-3 text-on-surface-variant text-body-md max-w-60 truncate">{v.reason}</td>
                  <td className="py-2.5 px-3">
                    <StatusPill
                      label={v.status}
                      color={v.status === "PENDING" ? "red" : v.status === "APPROVED" ? "green" : "gray"}
                    />
                  </td>
                  <td className="py-2.5 px-3 text-outline text-label-sm">
                    {new Date(v.createdAt).toLocaleDateString()}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </GlassPanel>

      {selected && (
        <div className="fixed inset-y-0 right-0 z-50 w-96 max-w-full bg-surface-container-high border-l border-white/10 shadow-2xl overflow-y-auto">
          <div className="p-6">
            <div className="flex justify-between items-center mb-4">
              <h2 className="font-sora text-headline-md text-on-background">Violation Detail</h2>
              <button onClick={() => setSelected(null)} className="text-outline hover:text-on-background">
                <span className="material-symbols-outlined">close</span>
              </button>
            </div>

            <div className="space-y-4 text-body-md">
              <div><span className="text-outline">Vehicle:</span> <span className="text-on-background font-mono-data">{selected.vehiclePlate || "Unknown"}</span></div>
              <div><span className="text-outline">Guard:</span> <span className="text-on-background">{selected.guardName}</span></div>
              <div><span className="text-outline">Lot:</span> <span className="text-on-background">{selected.lotName || "Unknown"}</span></div>
              <div><span className="text-outline">Reason:</span> <span className="text-on-background">{selected.reason}</span></div>
              <div><span className="text-outline">Status:</span> <StatusPill label={selected.status} color={selected.status === "PENDING" ? "red" : selected.status === "APPROVED" ? "green" : "gray"} /></div>
            </div>

            {selected.evidenceUrl && (
              <img src={selected.evidenceUrl} alt="Evidence" className="mt-4 rounded-lg border border-white/10 w-full" />
            )}

            {selected.status === "PENDING" && (
              <div className="mt-6 space-y-3">
                <textarea
                  placeholder="Resolution note (required)..."
                  value={note}
                  onChange={(e) => setNote(e.target.value)}
                  className="w-full bg-surface-container border border-white/10 rounded-lg px-3 py-2 text-on-background resize-none h-24 focus:outline-none focus:border-secondary-fixed/50"
                />
                <div className="flex gap-2">
                  <button
                    onClick={() => resolveViolation(selected.id, "APPROVED")}
                    className="flex-1 bg-secondary-fixed text-on-secondary-fixed font-label-md py-2 rounded-lg hover:opacity-90"
                  >
                    Approve
                  </button>
                  <button
                    onClick={() => resolveViolation(selected.id, "DISMISSED")}
                    className="flex-1 bg-error/20 text-error font-label-md py-2 rounded-lg hover:bg-error/30"
                  >
                    Dismiss
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      )}

      <Toast />
    </div>
  );
}
