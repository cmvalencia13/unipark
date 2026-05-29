import { GlassPanel } from "@/components/ui/GlassPanel";
import { OccupancyBar } from "@/components/ui/OccupancyBar";
import { serverFetch } from "@/lib/api";

interface AdminStats {
  lots: { name: string; capacityTotal: number; capacityUsed: number }[];
  todayScans: number;
  pendingViolations: number;
  totalUsers: number;
}

export const dynamic = "force-dynamic";
export const revalidate = 30;

export default async function DashboardPage() {
  const stats = await serverFetch<AdminStats>("/v1/admin/stats").catch(() => ({
    lots: [],
    todayScans: 0,
    pendingViolations: 0,
    totalUsers: 0,
  }));

  return (
    <div>
      <h1 className="font-sora text-headline-lg text-on-background mb-6">Dashboard</h1>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
        <GlassPanel>
          <div className="flex items-center gap-2 mb-1">
            <span className="material-symbols-outlined text-secondary-fixed text-sm">verified</span>
            <h2 className="font-label-md text-secondary-fixed uppercase tracking-wider">Occupancy Overview</h2>
          </div>
          <div className="text-display-lg font-bold font-sora text-on-background mt-2 mb-4">
            {stats.lots.length} <span className="text-body-md text-on-surface-variant font-normal">lots</span>
          </div>
          <div className="space-y-3">
            {stats.lots.map((lot) => (
              <div key={lot.name}>
                <div className="flex justify-between text-label-sm mb-1">
                  <span className="text-on-background">{lot.name}</span>
                </div>
                <OccupancyBar used={lot.capacityUsed} total={lot.capacityTotal} />
              </div>
            ))}
          </div>
        </GlassPanel>

        <GlassPanel>
          <div className="flex items-center gap-2 mb-1">
            <span className="material-symbols-outlined text-primary-fixed-dim text-sm">bar_chart</span>
            <h2 className="font-label-md text-primary-fixed-dim uppercase tracking-wider">Today's Activity</h2>
          </div>
          <div className="grid grid-cols-2 gap-4 mt-4">
            <div>
              <div className="text-display-lg font-bold font-sora text-on-background">{stats.todayScans}</div>
              <div className="text-label-sm text-outline">Scans</div>
            </div>
            <div>
              <div className="text-display-lg font-bold font-sora text-error">{stats.pendingViolations}</div>
              <div className="text-label-sm text-outline">Pending Violations</div>
            </div>
            <div className="col-span-2">
              <div className="text-display-lg font-bold font-sora text-on-background">{stats.totalUsers}</div>
              <div className="text-label-sm text-outline">Total Users</div>
            </div>
          </div>
        </GlassPanel>
      </div>
    </div>
  );
}
