import * as React from "react";
import { cn } from "#lib/utils";

type LogoProps = React.ComponentProps<"div"> & {
  compact?: boolean;
};

function Logo({ className, compact = false, ...props }: LogoProps) {
  return (
    <div className={cn("inline-flex items-center gap-3", className)} {...props}>
      <svg
        aria-hidden="true"
        viewBox="0 0 64 64"
        className="size-10 shrink-0"
        fill="none"
      >
        <path
          d="M11 53V27c0-8 5-12 10-16 4-3 8-6 11-9 3 3 7 6 11 9 5 4 10 8 10 16v26H11Z"
          stroke="currentColor"
          strokeWidth="2.6"
        />
        <path d="M27 51V24h10v27M30 24v-7h4v7M32 11v6" stroke="currentColor" strokeWidth="2.4" />
        <path d="M19 51V36h8v15M37 51V32h8v19" stroke="currentColor" strokeWidth="2.4" />
        <path d="M15 29c5-4 9-5 13-2-6 0-9 4-10 9" stroke="currentColor" strokeWidth="2.2" />
        <circle cx="47" cy="23" r="5" fill="currentColor" opacity="0.35" />
      </svg>
      {!compact && (
        <span className="font-display text-xl leading-none tracking-[-0.035em]">
          <span className="text-primary">My</span>
          <span className="text-foreground">Marrakesh</span>
          <span className="text-gold-foreground">Guide</span>
        </span>
      )}
      <span className="sr-only">MyMarrakeshGuide</span>
    </div>
  );
}

export { Logo };
export type { LogoProps };
