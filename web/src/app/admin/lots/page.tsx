"use client";

import { useState } from "react";
import useSWR from "swr";
import { GlassPanel } from "@/components/ui/GlassPanel";
import { OccupancyBar } from "@/components/ui/OccupancyBar";
import { StatusPill } from "@/components/ui/StatusPill";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { Toast, showToast } from "@/components/shared/Toast";
import { clientFetch } from "@/lib/api";

interface Lot {
  id: string;
  name: string;
  capacityTotal: number;
  capacityUsed: number;
  active: boolean;
}

const fetcher = (url: string) => clientFetch<Lot[]>(url);

export default function LotsPage() {
  const { data, isLoading, mutate } = useSWR("/v1/lots", fetcher);
  const [showNewModal, setShowNewModal] = useState(false);
  const [newName, setNewName] = useState("");
  const [newCapacity, setNewCapacity] = useState("");

  const createLot = async () => {
    try {
      await clientFetch("/v1/lots", {
        method: "POST",
        body: JSON.stringify({ name: newName, capacityTotal: parseInt(newCapacity) }),
      });
      mutate();
      setShowNewModal(false);
      setNewName("");
      setNewCapacity("");
      showToast("Lot created", "success");
    } catch {
      showToast("Failed to create lot", "error");
    }
  };

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h1 className="font-sora text-headline-lg text-on-background">Parking Lots</h1>
        <button
          onClick={() => setShowNewModal(true)}
          className="flex items-center gap-1.5 bg-secondary-fixed text-on-secondary-fixed font-label-md px-4 py-2 rounded-lg hover:opacity-90 transition-all"
        >
          <span className="material-symbols-outlined text-sm">add</span>
          New Lot
        </button>
      </div>

      <GlassPanel>
        {isLoading && <div className="text-on-surface-variant py-8 text-center">Loading...</div>}

        {data && (
          <table className="w-full border-collapse">
            <thead>
              <tr className="border-b border-white/5">
                <th className="text-left py-2 px-3 text-outline text-label-sm font-medium">Name</th>
                <th className="text-left py-2 px-3 text-outline text-label-sm font-medium">Capacity</th>
                <th className="text-left py-2 px-3 text-outline text-label-sm font-medium">Used</th>
                <th className="text-left py-2 px-3 text-outline text-label-sm font-medium">Occupancy</th>
                <th className="text-left py-2 px-3 text-outline text-label-sm font-medium">Status</th>
              </tr>
            </thead>
            <tbody>
              {data.map((lot) => (
                <tr key={lot.id} className="border-b border-white/[0.02] hover:bg-surface-container/30 transition-colors">
                  <td className="py-3 px-3 text-on-background text-body-md font-medium">{lot.name}</td>
                  <td className="py-3 px-3 text-on-surface-variant text-body-md">{lot.capacityTotal}</td>
                  <td className="py-3 px-3 text-on-surface-variant text-body-md">{lot.capacityUsed}</td>
                  <td className="py-3 px-3 min-w-[180px]">
                    <OccupancyBar used={lot.capacityUsed} total={lot.capacityTotal} />
                  </td>
                  <td className="py-3 px-3">
                    <StatusPill
                      label={lot.active ? "Active" : "Inactive"}
                      color={lot.active ? "green" : "gray"}
                    />
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </GlassPanel>

      {showNewModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center">
          <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={() => setShowNewModal(false)} />
          <div className="relative bg-surface-container-high border border-white/10 rounded-xl p-6 max-w-sm w-full mx-4 shadow-2xl">
            <h3 className="font-sora text-headline-md text-on-background mb-4">New Parking Lot</h3>
            <input
              type="text"
              placeholder="Lot name"
              value={newName}
              onChange={(e) => setNewName(e.target.value)}
              className="w-full bg-surface-container border border-white/10 rounded-lg px-3 py-2 text-on-background mb-3 focus:outline-none focus:border-secondary-fixed/50"
            />
            <input
              type="number"
              placeholder="Total capacity"
              value={newCapacity}
              onChange={(e) => setNewCapacity(e.target.value)}
              className="w-full bg-surface-container border border-white/10 rounded-lg px-3 py-2 text-on-background mb-4 focus:outline-none focus:border-secondary-fixed/50"
            />
            <div className="flex gap-3 justify-end">
              <button onClick={() => setShowNewModal(false)} className="px-4 py-2 rounded-lg text-on-surface-variant hover:text-on-background">Cancel</button>
              <button onClick={createLot} className="px-4 py-2 rounded-lg bg-secondary-fixed text-on-secondary-fixed font-label-md hover:opacity-90">Create</button>
            </div>
          </div>
        </div>
      )}

      <Toast />
    </div>
  );
}
