"use client";

import { Button } from "@mmg/ui/components/button";
import { useEffect } from "react";

export default function ErrorPage({
  error,
  reset,
}: Readonly<{ error: Error & { digest?: string }; reset: () => void }>) {
  useEffect(() => {
    console.error("Route rendering failed", { digest: error.digest, name: error.name });
  }, [error]);

  return (
    <main className="grid min-h-[70dvh] place-items-center px-6 py-20">
      <div className="max-w-lg text-center">
        <p className="text-sm font-semibold uppercase tracking-[0.2em] text-primary">Request interrupted</p>
        <h1 className="mt-3 font-display text-4xl tracking-[-0.04em]">We could not complete this page.</h1>
        <p className="mt-5 leading-7 text-muted-foreground">Your data remains safe. Retry the request or return later.</p>
        <Button className="mt-8" onClick={reset}>Try again</Button>
      </div>
    </main>
  );
}
