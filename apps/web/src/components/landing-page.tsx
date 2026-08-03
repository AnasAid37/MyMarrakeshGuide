import { Badge } from "@mmg/ui/components/badge";
import { Button } from "@mmg/ui/components/button";
import { Card, CardContent, CardHeader, CardTitle } from "@mmg/ui/components/card";
import { Logo } from "@mmg/ui/components/logo";
import { ArrowRight, Building2, CheckCircle2, Compass, Map, QrCode, ShieldCheck } from "lucide-react";
import Link from "next/link";
import { ArchIllustration } from "./arch-illustration";

const capabilities = [
  {
    icon: Compass,
    title: "Intelligent itineraries",
    description: "Plans organized around verified local inventory, opening hours, pace and budget.",
  },
  {
    icon: Map,
    title: "City-aware navigation",
    description: "Realistic geographic sequencing with clear map context and navigation handoff.",
  },
  {
    icon: ShieldCheck,
    title: "Validated recommendations",
    description: "The AI can arrange approved candidates; it can never invent a place.",
  },
] as const;

const hostCapabilities = [
  "Property-specific guest entry points",
  "Managed QR campaigns",
  "Privacy-preserving guest analytics",
  "Role-scoped team access",
] as const;

export function LandingPage() {
  return (
    <main className="overflow-hidden">
      <header className="relative z-20 border-b border-border/70 bg-background/85 backdrop-blur-xl">
        <div className="mx-auto flex h-20 max-w-7xl items-center justify-between px-5 sm:px-8 lg:px-10">
          <Link href="/" aria-label="MyMarrakeshGuide home">
            <Logo />
          </Link>
          <nav aria-label="Primary navigation" className="hidden items-center gap-8 text-sm font-medium md:flex">
            <Link className="transition-colors hover:text-primary" href="#traveler">For travelers</Link>
            <Link className="transition-colors hover:text-primary" href="#hosts">For hosts</Link>
            <Link className="transition-colors hover:text-primary" href="#trust">Our standard</Link>
          </nav>
          <Button asChild size="sm">
            <Link href="#traveler">Explore <ArrowRight aria-hidden="true" /></Link>
          </Button>
        </div>
      </header>

      <section id="traveler" className="relative isolate">
        <div aria-hidden="true" className="editorial-grid absolute inset-0 -z-20 opacity-45" />
        <div aria-hidden="true" className="absolute -right-36 top-16 -z-10 size-[38rem] rounded-full bg-gold/10 blur-3xl" />
        <div className="mx-auto grid max-w-7xl items-center gap-12 px-5 py-20 sm:px-8 sm:py-28 lg:grid-cols-[1.05fr_0.95fr] lg:px-10 lg:py-32">
          <div className="max-w-3xl">
            <Badge variant="outline" className="mb-7 border-primary/30 bg-background/70 px-3 py-1 text-primary">
              AI-powered Marrakesh concierge
            </Badge>
            <h1 className="font-display text-5xl leading-[0.98] tracking-[-0.05em] text-balance sm:text-6xl lg:text-7xl xl:text-[5.4rem]">
              Your Marrakesh experience, <span className="text-primary">crafted around you.</span>
            </h1>
            <p className="mt-7 max-w-2xl text-lg leading-8 text-muted-foreground sm:text-xl">
              Discover authentic places and move through the city with an itinerary built from verified local data—not generated guesses.
            </p>
            <div className="mt-10 flex flex-col gap-3 sm:flex-row">
              <Button asChild size="lg">
                <Link href="#platform">Discover the platform <ArrowRight aria-hidden="true" /></Link>
              </Button>
              <Button asChild size="lg" variant="outline">
                <Link href="#hosts">Hospitality partners</Link>
              </Button>
            </div>
            <div id="trust" className="mt-11 flex flex-wrap gap-x-7 gap-y-3 text-sm text-muted-foreground">
              {['Verified inventory only', 'Privacy by design', 'Mobile-first'].map((item) => (
                <span key={item} className="inline-flex items-center gap-2">
                  <CheckCircle2 aria-hidden="true" className="size-4 text-secondary" />
                  {item}
                </span>
              ))}
            </div>
          </div>

          <div className="relative mx-auto w-full max-w-[590px]">
            <div aria-hidden="true" className="absolute inset-10 rounded-full bg-primary/15 blur-3xl" />
            <div className="luxury-panel relative rounded-[2.4rem] border border-white/50 p-5 sm:p-8">
              <ArchIllustration />
              <div className="absolute bottom-8 left-8 right-8 rounded-2xl border border-white/55 bg-background/85 p-4 shadow-xl backdrop-blur-xl sm:bottom-11 sm:left-11 sm:right-11 sm:p-5">
                <p className="text-xs font-semibold uppercase tracking-[0.18em] text-primary">Recommendation standard</p>
                <p className="mt-2 font-display text-xl leading-snug">Every activity resolves to a validated place in our catalog.</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section id="platform" className="border-y border-border/70 bg-card/60 py-20 sm:py-24">
        <div className="mx-auto max-w-7xl px-5 sm:px-8 lg:px-10">
          <div className="max-w-2xl">
            <p className="text-sm font-semibold uppercase tracking-[0.18em] text-primary">One trusted journey</p>
            <h2 className="mt-3 font-display text-4xl tracking-[-0.035em] sm:text-5xl">Local intelligence, elegantly organized.</h2>
          </div>
          <div className="mt-12 grid gap-5 md:grid-cols-3">
            {capabilities.map(({ icon: Icon, title, description }) => (
              <Card key={title} className="h-full border-border/60 bg-background/80">
                <CardHeader>
                  <div className="mb-5 grid size-11 place-items-center rounded-xl bg-accent text-primary">
                    <Icon aria-hidden="true" className="size-5" />
                  </div>
                  <CardTitle>{title}</CardTitle>
                </CardHeader>
                <CardContent className="text-sm leading-7 text-muted-foreground">{description}</CardContent>
              </Card>
            ))}
          </div>
        </div>
      </section>

      <section id="hosts" className="py-20 sm:py-28">
        <div className="mx-auto grid max-w-7xl gap-12 px-5 sm:px-8 lg:grid-cols-2 lg:px-10">
          <div className="rounded-[2rem] bg-secondary p-8 text-secondary-foreground sm:p-12">
            <Building2 aria-hidden="true" className="size-9 text-gold" />
            <p className="mt-10 text-sm font-semibold uppercase tracking-[0.18em] text-gold">For riads, hotels and hosts</p>
            <h2 className="mt-4 font-display text-4xl tracking-[-0.035em] sm:text-5xl">Turn every stay into a curated local welcome.</h2>
            <p className="mt-6 max-w-xl leading-7 text-secondary-foreground/75">
              Give guests a high-quality digital concierge while your team keeps control of property context, access and service insights.
            </p>
          </div>
          <div className="flex flex-col justify-center">
            <QrCode aria-hidden="true" className="size-8 text-primary" />
            <h3 className="mt-6 font-display text-3xl tracking-[-0.03em]">A hospitality platform built for trust.</h3>
            <ul className="mt-8 space-y-5">
              {hostCapabilities.map((capability) => (
                <li key={capability} className="flex items-start gap-3 border-b border-border pb-5">
                  <CheckCircle2 aria-hidden="true" className="mt-0.5 size-5 shrink-0 text-secondary" />
                  <span className="font-medium">{capability}</span>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </section>

      <footer className="border-t border-border bg-card/60">
        <div className="mx-auto flex max-w-7xl flex-col gap-5 px-5 py-9 sm:flex-row sm:items-center sm:justify-between sm:px-8 lg:px-10">
          <Logo />
          <p className="text-sm text-muted-foreground">Your journey, perfectly crafted.</p>
        </div>
      </footer>
    </main>
  );
}
