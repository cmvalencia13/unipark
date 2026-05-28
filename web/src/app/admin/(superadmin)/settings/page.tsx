"use client";

import { useState } from "react";
import useSWR from "swr";
import { GlassPanel } from "@/components/ui/GlassPanel";
import { Toast, showToast } from "@/components/shared/Toast";
import { clientFetch } from "@/lib/api";

interface SystemSettings {
  occupancyWarningPercent: number;
  occupancyCriticalPercent: number;
  rateLimitRequests: number;
  rateLimitWindowSeconds: number;
  qrExpirySeconds: number;
  maintenanceMode: boolean;
}

const fetcher = (url: string) => clientFetch<SystemSettings>(url);

export default function SettingsPage() {
  const { data, isLoading, mutate } = useSWR("/v1/admin/settings", fetcher);
  const [saving, setSaving] = useState<string | null>(null);

  const save = async (key: string, body: Record<string, any>) => {
    setSaving(key);
    try {
      await clientFetch("/v1/admin/settings", { method: "PATCH", body: JSON.stringify(body) });
      mutate();
      showToast("Settings updated", "success");
    } catch {
      showToast("Failed to save settings", "error");
    }
    setSaving(null);
  };

  if (isLoading) return <div className="text-on-surface-variant py-8 text-center">Loading...</div>;
  if (!data) return null;

  return (
    <div>
      <h1 className="font-sora text-headline-lg text-on-background mb-6">Settings</h1>

      <div className="space-y-4 max-w-2xl">
        <GlassPanel>
          <h2 className="font-sora text-headline-md text-on-background mb-4">Occupancy Thresholds</h2>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="text-outline text-label-sm block mb-1">Warning (%)</label>
              <input
                type="number"
                defaultValue={data.occupancyWarningPercent}
                id="warningPct"
                className="w-full bg-surface-container border border-white/10 rounded-lg px-3 py-2 text-on-background focus:outline-none focus:border-secondary-fixed/50"
              />
            </div>
            <div>
              <label className="text-outline text-label-sm block mb-1">Critical (%)</label>
              <input
                type="number"
                defaultValue={data.occupancyCriticalPercent}
                id="criticalPct"
                className="w-full bg-surface-container border border-white/10 rounded-lg px-3 py-2 text-on-background focus:outline-none focus:border-secondary-fixed/50"
              />
            </div>
          </div>
          <button
            onClick={() => save("occupancy", {
              occupancyWarningPercent: parseInt((document.getElementById("warningPct") as HTMLInputElement).value),
              occupancyCriticalPercent: parseInt((document.getElementById("criticalPct") as HTMLInputElement).value),
            })}
            disabled={saving === "occupancy"}
            className="mt-4 px-4 py-2 rounded-lg bg-secondary-fixed text-on-secondary-fixed font-label-md hover:opacity-90 disabled:opacity-50"
          >
            {saving === "occupancy" ? "Saving..." : "Save Thresholds"}
          </button>
        </GlassPanel>

        <GlassPanel>
          <h2 className="font-sora text-headline-md text-on-background mb-4">Rate Limiting</h2>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="text-outline text-label-sm block mb-1">Requests per window</label>
              <input
                type="number"
                defaultValue={data.rateLimitRequests}
                id="rlRequests"
                className="w-full bg-surface-container border border-white/10 rounded-lg px-3 py-2 text-on-background focus:outline-none focus:border-secondary-fixed/50"
              />
            </div>
            <div>
              <label className="text-outline text-label-sm block mb-1">Window (seconds)</label>
              <input
                type="number"
                defaultValue={data.rateLimitWindowSeconds}
                id="rlWindow"
                className="w-full bg-surface-container border border-white/10 rounded-lg px-3 py-2 text-on-background focus:outline-none focus:border-secondary-fixed/50"
              />
            </div>
          </div>
          <button
            onClick={() => save("ratelimit", {
              rateLimitRequests: parseInt((document.getElementById("rlRequests") as HTMLInputElement).value),
              rateLimitWindowSeconds: parseInt((document.getElementById("rlWindow") as HTMLInputElement).value),
            })}
            disabled={saving === "ratelimit"}
            className="mt-4 px-4 py-2 rounded-lg bg-secondary-fixed text-on-secondary-fixed font-label-md hover:opacity-90 disabled:opacity-50"
          >
            {saving === "ratelimit" ? "Saving..." : "Save Rate Limits"}
          </button>
        </GlassPanel>

        <GlassPanel>
          <h2 className="font-sora text-headline-md text-on-background mb-4">QR Pass</h2>
          <div>
            <label className="text-outline text-label-sm block mb-1">Expiry (seconds)</label>
            <input
              type="number"
              defaultValue={data.qrExpirySeconds}
              id="qrExpiry"
              className="w-full bg-surface-container border border-white/10 rounded-lg px-3 py-2 text-on-background focus:outline-none focus:border-secondary-fixed/50"
            />
          </div>
          <button
            onClick={() => save("qr", {
              qrExpirySeconds: parseInt((document.getElementById("qrExpiry") as HTMLInputElement).value),
            })}
            disabled={saving === "qr"}
            className="mt-4 px-4 py-2 rounded-lg bg-secondary-fixed text-on-secondary-fixed font-label-md hover:opacity-90 disabled:opacity-50"
          >
            {saving === "qr" ? "Saving..." : "Save QR Expiry"}
          </button>
        </GlassPanel>

        <GlassPanel>
          <h2 className="font-sora text-headline-md text-on-background mb-4">Maintenance Mode</h2>
          <div className="flex items-center gap-3">
            <button
              onClick={() => save("maintenance", { maintenanceMode: !data.maintenanceMode })}
              className={`relative w-12 h-6 rounded-full transition-colors ${
                data.maintenanceMode ? "bg-error" : "bg-surface-variant"
              }`}
            >
              <div className={`absolute top-0.5 w-5 h-5 bg-white rounded-full transition-transform ${
                data.maintenanceMode ? "translate-x-6" : "translate-x-0.5"
              }`} />
            </button>
            <span className="text-on-background text-body-md">
              {data.maintenanceMode ? "Maintenance mode is ON" : "Maintenance mode is OFF"}
            </span>
          </div>
        </GlassPanel>
      </div>

      <Toast />
    </div>
  );
}
