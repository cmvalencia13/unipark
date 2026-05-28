import { ReactNode } from "react";

interface GlassPanelProps {
  children: ReactNode;
  className?: string;
  glow?: boolean;
}

export function GlassPanel({ children, className = "", glow = false }: GlassPanelProps) {
  return (
    <div
      className={`bg-surface-container/60 backdrop-blur-xl border-t border-l border-white/10 border-r border-black/20 border-b border-black/20 rounded-xl p-md ${
        glow ? "shadow-[0_0_24px_rgba(54,255,196,0.25)]" : ""
      } ${className}`}
    >
      {children}
    </div>
  );
}
