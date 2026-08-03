import * as React from "react";
import { type VariantProps, cva } from "class-variance-authority";
import { cn } from "#lib/utils";

const badgeVariants = cva(
  "inline-flex w-fit items-center justify-center gap-1 overflow-hidden rounded-full border px-3 py-1 text-[0.7rem] font-semibold uppercase tracking-[0.14em] whitespace-nowrap",
  {
    variants: {
      variant: {
        default: "border-transparent bg-primary/10 text-primary",
        secondary: "border-transparent bg-secondary text-secondary-foreground",
        outline: "border-border bg-background text-foreground",
        gold: "border-gold/30 bg-gold/12 text-gold-foreground",
      },
    },
    defaultVariants: {
      variant: "default",
    },
  },
);

type BadgeProps = React.ComponentProps<"span"> & VariantProps<typeof badgeVariants>;

function Badge({ className, variant, ...props }: BadgeProps) {
  return (
    <span
      data-slot="badge"
      className={cn(badgeVariants({ variant }), className)}
      {...props}
    />
  );
}

export { Badge, badgeVariants };
export type { BadgeProps };
