'use client';

import { Alert } from '@/types';
import { AlertCircle, AlertTriangle, Info } from 'lucide-react';

interface AlertsListProps {
  alerts: Alert[];
  loading?: boolean;
}

export function AlertsList({ alerts, loading = false }: AlertsListProps) {
  if (loading) {
    return (
      <div className="w-full bg-slate-900 rounded-lg p-6 border border-slate-800">
        <h3 className="text-lg font-semibold text-white mb-4">Alertas del Sistema</h3>
        <div className="space-y-2">
          {[...Array(3)].map((_, i) => (
            <div key={i} className="h-16 bg-slate-800 rounded animate-pulse" />
          ))}
        </div>
      </div>
    );
  }

  const getIcon = (type: string) => {
    switch (type) {
      case 'error':
        return <AlertCircle className="w-5 h-5 text-red-500" />;
      case 'warning':
        return <AlertTriangle className="w-5 h-5 text-yellow-500" />;
      case 'info':
      default:
        return <Info className="w-5 h-5 text-blue-500" />;
    }
  };

  const getBgColor = (type: string) => {
    switch (type) {
      case 'error':
        return 'bg-red-500/10 border-red-500/20';
      case 'warning':
        return 'bg-yellow-500/10 border-yellow-500/20';
      case 'info':
      default:
        return 'bg-blue-500/10 border-blue-500/20';
    }
  };

  return (
    <div className="w-full bg-slate-900 rounded-lg p-6 border border-slate-800">
      <h3 className="text-lg font-semibold text-white mb-4">Alertas del Sistema</h3>

      {alerts.length === 0 ? (
        <p className="text-slate-400 text-center py-8">No hay alertas</p>
      ) : (
        <div className="space-y-3">
          {alerts.map((alert) => (
            <div
              key={alert.id}
              className={`p-4 rounded-lg border ${getBgColor(alert.type)}`}
            >
              <div className="flex gap-3">
                {getIcon(alert.type)}
                <div className="flex-1">
                  <h4 className="font-semibold text-white">{alert.title}</h4>
                  <p className="text-sm text-slate-300 mt-1">{alert.message}</p>
                  <p className="text-xs text-slate-500 mt-2">
                    {new Date(alert.timestamp).toLocaleString()}
                  </p>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
