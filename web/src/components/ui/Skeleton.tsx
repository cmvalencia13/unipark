interface SkeletonProps {
  className?: string;
}

export function Skeleton({ className = "" }: SkeletonProps) {
  return (
    <div
      className={`relative overflow-hidden bg-surface-container rounded-lg ${className}`}
    >
      <div className="absolute inset-0 shimmer-effect" />
    </div>
  );
}

export function CardSkeleton() {
  return (
    <div className="glass-panel rounded-xl p-md space-y-3">
      <Skeleton className="h-4 w-24" />
      <Skeleton className="h-8 w-32" />
      <Skeleton className="h-2 w-full" />
    </div>
  );
}
