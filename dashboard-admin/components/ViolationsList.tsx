'use client';

import { Violation } from '@/types';
import { CheckCircle, XCircle, Clock } from 'lucide-react';
import { useState } from 'react';

interface ViolationsListProps {
  violations: Violation[];
  loading?: boolean;
  onUpdateViolation?: (id: string, status: string) => void;
}

export function ViolationsList({
  violations,
  loading = false,
  onUpdateViolation,
}: ViolationsListProps) {
  const [updating, setUpdating] = useState<string | null>(null);

  if (loading) {
    return (
      <div className="w-full bg-slate-900 rounded-lg p-6 border border-slate-800">
        <h3 className="text-lg font-semibold text-white mb-4">Violaciones</h3>
        <div className="space-y-2">
          {[...Array(3)].map((_, i) => (
            <div key={i} className="h-20 bg-slate-800 rounded animate-pulse" />
          ))}
        </div>
      </div>
    );
  }

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'APPROVED':
        return <CheckCircle className="w-5 h-5 text-green-500" />;
      case 'DISMISSED':
        return <XCircle className="w-5 h-5 text-red-500" />;
      case 'PENDING':
      default:
        return <Clock className="w-5 h-5 text-yellow-500" />;
    }
  };

  const getStatusBg = (status: string) => {
    switch (status) {
      case 'APPROVED':
        return 'bg-green-500/10 text-green-400 border-green-500/20';
      case 'DISMISSED':
        return 'bg-red-500/10 text-red-400 border-red-500/20';
      case 'PENDING':
      default:
        return 'bg-yellow-500/10 text-yellow-400 border-yellow-500/20';
    }
  };

  return (
    <div className="w-full bg-slate-900 rounded-lg p-6 border border-slate-800">
      <h3 className="text-lg font-semibold text-white mb-4">Violaciones Pendientes</h3>

      {violations.length === 0 ? (
        <p className="text-slate-400 text-center py-8">No hay violaciones</p>
      ) : (
        <div className="space-y-3 max-h-96 overflow-y-auto">
          {violations.map((violation) => (
            <div
              key={violation.id}
              className="p-4 rounded-lg border border-slate-700 bg-slate-800/50 hover:bg-slate-800 transition"
            >
              <div className="flex items-start justify-between gap-4">
                <div className="flex-1">
                  <h4 className="font-semibold text-white">{violation.licenseplate}</h4>
                  <p className="text-sm text-slate-300 mt-1">{violation.description}</p>
                  <p className="text-xs text-slate-500 mt-2">
                    {new Date(violation.timestamp).toLocaleString()} • Lote {violation.lotId}
                  </p>
                </div>

                <div className="flex flex-col items-end gap-2">
                  <div
                    className={`flex items-center gap-1 px-2 py-1 rounded border text-xs font-medium ${getStatusBg(
                      violation.status
                    )}`}
                  >
                    {getStatusIcon(violation.status)}
                    {violation.status}
                  </div>

                  {violation.status === 'PENDING' && onUpdateViolation && (
                    <div className="flex gap-2">
                      <button
                        disabled={updating === violation.id}
                        onClick={() => {
                          setUpdating(violation.id);
                          onUpdateViolation(violation.id, 'APPROVED');
                          setTimeout(() => setUpdating(null), 500);
                        }}
                        className="px-2 py-1 text-xs bg-green-600 hover:bg-green-700 text-white rounded transition disabled:opacity-50"
                      >
                        Aprobar
                      </button>
                      <button
                        disabled={updating === violation.id}
                        onClick={() => {
                          setUpdating(violation.id);
                          onUpdateViolation(violation.id, 'DISMISSED');
                          setTimeout(() => setUpdating(null), 500);
                        }}
                        className="px-2 py-1 text-xs bg-red-600 hover:bg-red-700 text-white rounded transition disabled:opacity-50"
                      >
                        Rechazar
                      </button>
                    </div>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
