"use client";

import { useState } from "react";
import useSWR from "swr";
import { GlassPanel } from "@/components/ui/GlassPanel";
import { clientFetch } from "@/lib/api";

interface AuditEntry {
  id: number;
  actorId: string | null;
  action: string;
  targetId: string | null;
  payload: Record<string, any> | null;
  ip: string | null;
  createdAt: string;
}

interface PageResponse<T> {
  content: T[];
  totalPages: number;
  totalElements: number;
  number: number;
}

const fetcher = (url: string) => clientFetch<PageResponse<AuditEntry>>(url);

export default function AuditPage() {
  const [page, setPage] = useState(0);
  const [from, setFrom] = useState("");
  const [to, setTo] = useState("");
  const [actionFilter, setActionFilter] = useState("");
  const [expanded, setExpanded] = useState<number | null>(null);

  const params = new URLSearchParams({ page: String(page), size: "50" });
  if (from) params.set("from", new Date(from).toISOString());
  if (to) params.set("to", new Date(to).toISOString());
  if (actionFilter) params.set("action", actionFilter);

  const { data, isLoading } = useSWR(`/v1/admin/audit?${params}`, fetcher);

  return (
    <div>
      <h1 className="font-sora text-headline-lg text-on-background mb-6">Audit Log</h1>

      <GlassPanel>
        <div className="flex flex-wrap gap-3 mb-4">
          <input
            type="date"
            value={from}
            onChange={(e) => { setFrom(e.target.value); setPage(0); }}
            className="bg-surface-container border border-white/10 rounded-lg px-3 py-2 text-on-background text-body-md focus:outline-none focus:border-secondary-fixed/50"
          />
          <input
            type="date"
            value={to}
            onChange={(e) => { setTo(e.target.value); setPage(0); }}
            className="bg-surface-container border border-white/10 rounded-lg px-3 py-2 text-on-background text-body-md focus:outline-none focus:border-secondary-fixed/50"
          />
          <input
            type="text"
            value={actionFilter}
            onChange={(e) => { setActionFilter(e.target.value); setPage(0); }}
            placeholder="Filter by action..."
            className="bg-surface-container border border-white/10 rounded-lg px-3 py-2 text-on-background text-body-md placeholder:text-outline focus:outline-none focus:border-secondary-fixed/50"
          />
        </div>

        {isLoading && <div className="text-on-surface-variant py-8 text-center">Loading...</div>}

        {data && (
          <table className="w-full border-collapse">
            <thead>
              <tr className="border-b border-white/5">
                <th className="text-left py-2 px-2 text-outline text-label-sm font-medium w-40">Timestamp</th>
                <th className="text-left py-2 px-2 text-outline text-label-sm font-medium">Action</th>
                <th className="text-left py-2 px-2 text-outline text-label-sm font-medium">Actor</th>
                <th className="text-left py-2 px-2 text-outline text-label-sm font-medium">IP</th>
              </tr>
            </thead>
            <tbody>
              {data.content.map((entry) => (
                <>
                  <tr
                    key={entry.id}
                    onClick={() => setExpanded(expanded === entry.id ? null : entry.id)}
                    className="border-b border-white/[0.02] hover:bg-surface-container/30 transition-colors cursor-pointer"
                  >
                    <td className="py-2 px-2 text-outline text-label-sm font-mono">{new Date(entry.createdAt).toLocaleString()}</td>
                    <td className="py-2 px-2 text-on-background text-body-md">{entry.action}</td>
                    <td className="py-2 px-2 text-on-surface-variant text-body-md font-mono text-xs">{entry.actorId || "—"}</td>
                    <td className="py-2 px-2 text-outline text-label-sm">{entry.ip || "—"}</td>
                  </tr>
                  {expanded === entry.id && (
                    <tr key={`${entry.id}-expanded`}>
                      <td colSpan={4} className="py-3 px-4 bg-surface-container/20">
                        <div className="text-outline text-label-sm mb-1">Payload</div>
                        <pre className="text-on-surface-variant text-body-md font-mono text-xs whitespace-pre-wrap">
                          {JSON.stringify(entry.payload, null, 2) || "—"}
                        </pre>
                      </td>
                    </tr>
                  )}
                </>
              ))}
            </tbody>
          </table>
        )}
      </GlassPanel>
    </div>
  );
}
