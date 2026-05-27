'use client';

import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  BarChart,
  Bar,
} from 'recharts';
import { ParkingLot } from '@/types';

interface OccupancyChartProps {
  lots: ParkingLot[];
}

export function OccupancyChart({ lots }: OccupancyChartProps) {
  const data = lots.map((lot) => ({
    name: lot.name,
    used: lot.capacityUsed,
    total: lot.capacity,
    percentage: lot.percentage,
  }));

  return (
    <div className="w-full h-96 bg-slate-900 rounded-lg p-6 border border-slate-800">
      <h3 className="text-lg font-semibold text-white mb-4">Ocupancia de Lotes</h3>
      <ResponsiveContainer width="100%" height="100%">
        <BarChart data={data}>
          <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
          <XAxis dataKey="name" stroke="#9CA3AF" />
          <YAxis stroke="#9CA3AF" />
          <Tooltip
            contentStyle={{
              backgroundColor: '#1F2937',
              border: '1px solid #374151',
              color: '#F3F4F6',
            }}
          />
          <Legend />
          <Bar dataKey="used" fill="#3B82F6" name="Ocupado" />
          <Bar dataKey="total" fill="#10B981" name="Capacidad" />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}

export function OccupancyPercentageChart({ lots }: OccupancyChartProps) {
  const data = lots.map((lot) => ({
    name: lot.name,
    percentage: Math.round(lot.percentage),
  }));

  return (
    <div className="w-full h-80 bg-slate-900 rounded-lg p-6 border border-slate-800">
      <h3 className="text-lg font-semibold text-white mb-4">% Ocupancia</h3>
      <ResponsiveContainer width="100%" height="100%">
        <LineChart data={data}>
          <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
          <XAxis dataKey="name" stroke="#9CA3AF" />
          <YAxis stroke="#9CA3AF" domain={[0, 100]} />
          <Tooltip
            contentStyle={{
              backgroundColor: '#1F2937',
              border: '1px solid #374151',
              color: '#F3F4F6',
            }}
          />
          <Line
            type="monotone"
            dataKey="percentage"
            stroke="#F59E0B"
            strokeWidth={2}
            name="Porcentaje"
            dot={{ fill: '#F59E0B', r: 4 }}
          />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}
