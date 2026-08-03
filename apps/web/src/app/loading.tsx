export default function Loading() {
  return (
    <main aria-busy="true" aria-label="Loading MyMarrakeshGuide" className="grid min-h-dvh place-items-center px-6">
      <div className="text-center">
        <div className="mx-auto size-11 animate-pulse rounded-full border-2 border-primary border-t-transparent" />
        <p className="mt-5 text-sm font-medium text-muted-foreground">Preparing your experience…</p>
      </div>
    </main>
  );
}
