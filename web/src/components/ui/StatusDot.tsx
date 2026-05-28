interface StatusDotProps {
  active: boolean;
}

export function StatusDot({ active }: StatusDotProps) {
  return (
    <span
      className={`inline-block w-2 h-2 rounded-full ${
        active
          ? "bg-secondary-fixed shadow-[0_0_8px_rgba(54,255,196,0.8)]"
          : "bg-outline"
      }`}
    />
  );
}
