type StatusColor = "green" | "cyan" | "purple" | "red" | "gray";

const colorMap: Record<StatusColor, { bg: string; text: string }> = {
  green: { bg: "bg-secondary-fixed/10", text: "text-secondary-fixed" },
  cyan: { bg: "bg-primary-fixed/10", text: "text-primary-fixed-dim" },
  purple: { bg: "bg-tertiary-fixed-dim/10", text: "text-tertiary-fixed-dim" },
  red: { bg: "bg-error/10", text: "text-error" },
  gray: { bg: "bg-surface-variant/30", text: "text-outline" },
};

interface StatusPillProps {
  label: string;
  color?: StatusColor;
}

export function StatusPill({ label, color = "gray" }: StatusPillProps) {
  const c = colorMap[color];
  return (
    <span className={`inline-block px-2 py-0.5 rounded text-label-sm ${c.bg} ${c.text}`}>
      {label}
    </span>
  );
}
