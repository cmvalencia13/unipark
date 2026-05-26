'use client';

import { ReactNode } from 'react';
import { TrendingUp, TrendingDown } from 'lucide-react';

interface StatsCardProps {
  title: string;
  value: string | number;
  description?: string;
  icon?: ReactNode;
  trend?: {
    value: number;
    isUp: boolean;
  };
  className?: string;
}

export function StatsCard({
  title,
  value,
  description,
  icon,
  trend,
  className,
}: StatsCardProps) {
  return (
    <div
      className={`bg-slate-900 rounded-lg p-6 border border-slate-800 hover:border-slate-700 transition ${className}`}
    >
      <div className="flex items-start justify-between">
        <div className="flex-1">
          <p className="text-slate-400 text-sm font-medium">{title}</p>
          <p className="text-3xl font-bold text-white mt-2">{value}</p>
          {description && <p className="text-slate-500 text-sm mt-2">{description}</p>}
        </div>
        {icon && <div className="text-slate-600 w-12 h-12 flex items-center justify-center">{icon}</div>}
      </div>

      {trend && (
        <div className="flex items-center gap-1 mt-4">
          {trend.isUp ? (
            <TrendingUp className="w-4 h-4 text-green-500" />
          ) : (
            <TrendingDown className="w-4 h-4 text-red-500" />
          )}
          <span
            className={`text-sm font-medium ${trend.isUp ? 'text-green-500' : 'text-red-500'}`}
          >
            {trend.isUp ? '+' : '-'}
            {Math.abs(trend.value)}%
          </span>
        </div>
      )}
    </div>
  );
}
