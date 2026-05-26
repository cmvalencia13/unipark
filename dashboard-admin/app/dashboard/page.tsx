'use client';

import { useSession, signOut } from 'next-auth/react';
import { useEffect, useState } from 'react';
import { LogOut, ParkingCircle } from 'lucide-react';
import { api } from '@/lib/api-client';
import { OccupancyChart, OccupancyPercentageChart } from '@/components/OccupancyChart';
import { AlertsList } from '@/components/AlertsList';
import { ViolationsList } from '@/components/ViolationsList';
import { StatsCard } from '@/components/StatsCard';
import { useOccupancy } from '@/hooks/useOccupancy';
import { ParkingLot, Violation, Alert } from '@/types';

export default function DashboardPage() {
  const { data: session } = useSession();
  const { lots, loading: lotsLoading } = useOccupancy();
  const [violations, setViolations] = useState<Violation[]>([]);
  const [alerts, setAlerts] = useState<Alert[]>([]);
  const [loadingViolations, setLoadingViolations] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        // Fetch violations
        const violationsRes = await api.getViolations('PENDING');
        setViolations(violationsRes.data);

        // Generate mock alerts for demo
        setAlerts([
          {
            id: '1',
            title: 'Mantenimiento programado',
            message: 'Lote Sur (Deck 2-3) cerrado para reparación. 28-30 de mayo.',
            type: 'warning',
            timestamp: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString(),
          },
          {
            id: '2',
            title: 'Evento de estacionamiento',
            message: 'Evento en el estadio hoy a las 6 PM. Lotes Este y Arena reservados.',
            type: 'info',
            timestamp: new Date(Date.now() - 5 * 60 * 60 * 1000).toISOString(),
          },
        ]);
      } catch (error) {
        console.error('Failed to fetch data:', error);
      } finally {
        setLoadingViolations(false);
      }
    };

    fetchData();
  }, []);

  const handleUpdateViolation = async (violationId: string, status: string) => {
    try {
      await api.updateViolation(violationId, { status });
      setViolations((prev) => prev.filter((v) => v.id !== violationId));
    } catch (error) {
      console.error('Failed to update violation:', error);
    }
  };

  const totalCapacity = lots.reduce((sum, lot) => sum + lot.capacity, 0);
  const totalUsed = lots.reduce((sum, lot) => sum + lot.capacityUsed, 0);
  const avgOccupancy =
    lots.length > 0 ? Math.round((totalUsed / totalCapacity) * 100) : 0;

  return (
    <div className="min-h-screen bg-slate-950">
      {/* Header */}
      <header className="sticky top-0 z-50 border-b border-slate-800 bg-slate-900/50 backdrop-blur">
        <div className="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <ParkingCircle className="w-8 h-8 text-blue-500" />
            <h1 className="text-2xl font-bold text-white">UniPark Dashboard</h1>
          </div>

          <div className="flex items-center gap-4">
            <div className="text-right">
              <p className="text-sm text-slate-400">Conectado como</p>
              <p className="font-semibold text-white">{session?.user?.email}</p>
            </div>
            <button
              onClick={() => signOut({ callbackUrl: '/auth/signin' })}
              className="p-2 hover:bg-slate-800 rounded-lg transition flex items-center gap-2 text-slate-400 hover:text-white"
            >
              <LogOut className="w-5 h-5" />
            </button>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-6 py-8">
        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
          <StatsCard
            title="Capacidad Total"
            value={totalCapacity}
            description="espacios de parqueo"
          />
          <StatsCard
            title="Espacios Ocupados"
            value={totalUsed}
            description={`${Math.round((totalUsed / totalCapacity) * 100)}% ocupado`}
          />
          <StatsCard
            title="Ocupancia Promedio"
            value={`${avgOccupancy}%`}
            trend={{ value: avgOccupancy > 70 ? 5 : -3, isUp: avgOccupancy > 70 }}
          />
          <StatsCard
            title="Violaciones Pendientes"
            value={violations.length}
            description="requieren revisión"
          />
        </div>

        {/* Charts */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
          <OccupancyChart lots={lots} />
          <OccupancyPercentageChart lots={lots} />
        </div>

        {/* Lists */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <AlertsList alerts={alerts} loading={false} />
          <ViolationsList
            violations={violations}
            loading={loadingViolations}
            onUpdateViolation={handleUpdateViolation}
          />
        </div>

        {/* Lotes Detallados */}
        <div className="mt-8 bg-slate-900 rounded-lg p-6 border border-slate-800">
          <h3 className="text-lg font-semibold text-white mb-4">Lotes en Tiempo Real</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {lots.map((lot) => (
              <div
                key={lot.id}
                className="p-4 rounded-lg border border-slate-700 bg-slate-800/50"
              >
                <h4 className="font-semibold text-white mb-3">{lot.name}</h4>
                <div className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span className="text-slate-400">Ocupancia</span>
                    <span className="text-white font-semibold">
                      {lot.capacityUsed}/{lot.capacity}
                    </span>
                  </div>
                  <div className="w-full bg-slate-700 rounded-full h-2">
                    <div
                      className={`h-2 rounded-full transition-all ${
                        lot.percentage > 80
                          ? 'bg-red-500'
                          : lot.percentage > 60
                          ? 'bg-yellow-500'
                          : 'bg-green-500'
                      }`}
                      style={{ width: `${lot.percentage}%` }}
                    />
                  </div>
                  <div className="flex justify-between text-xs text-slate-500 pt-1">
                    <span>{Math.round(lot.percentage)}%</span>
                    <span className="text-slate-400">
                      {lot.capacity - lot.capacityUsed} espacios libres
                    </span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </main>
    </div>
  );
}
