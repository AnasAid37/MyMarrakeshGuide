import { Button } from "@mmg/ui/components/button";
import { Logo } from "@mmg/ui/components/logo";
import Link from "next/link";

export default function NotFound() {
  return (
    <main className="grid min-h-dvh place-items-center px-6 py-20">
      <div className="max-w-xl text-center">
        <Logo className="justify-center" />
        <p className="mt-12 text-sm font-semibold uppercase tracking-[0.2em] text-primary">404</p>
        <h1 className="mt-3 font-display text-5xl tracking-[-0.04em]">This route is not on the itinerary.</h1>
        <p className="mt-5 leading-7 text-muted-foreground">The page may have moved or the address may be incorrect.</p>
        <Button asChild className="mt-9"><Link href="/">Return home</Link></Button>
      </div>
    </main>
  );
}
