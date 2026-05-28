interface OccupancyBarProps {
  used: number;
  total: number;
  className?: string;
}

export function OccupancyBar({ used, total, className = "" }: OccupancyBarProps) {
  const pct = Math.round((used / total) * 100);
  const isCritical = pct > 90;
  const isWarning = pct > 80;

  return (
    <div className={`flex items-center gap-2 ${className}`}>
      <div className="flex-1 h-1.5 bg-surface-variant rounded-full overflow-hidden">
        <div
          className={`h-full rounded-full ${
            isCritical
              ? "bg-error shadow-[0_0_8px_rgba(255,180,171,0.6)]"
              : isWarning
                ? "bg-primary-fixed-dim shadow-[0_0_8px_rgba(0,219,233,0.4)]"
                : "bg-secondary-fixed shadow-[0_0_8px_rgba(54,255,196,0.6)]"
          }`}
          style={{ width: `${pct}%` }}
        />
      </div>
      <span className={`font-mono-data text-label-sm ${isCritical ? "text-error" : "text-secondary-fixed"}`}>
        {pct}%
      </span>
    </div>
  );
}
