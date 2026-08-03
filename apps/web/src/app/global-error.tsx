"use client";

export default function GlobalError({ reset }: Readonly<{ error: Error; reset: () => void }>) {
  return (
    <html lang="en">
      <body>
        <main style={{ minHeight: "100vh", display: "grid", placeItems: "center", padding: "2rem", fontFamily: "system-ui" }}>
          <div style={{ maxWidth: "34rem", textAlign: "center" }}>
            <h1>MyMarrakeshGuide is temporarily unavailable.</h1>
            <p>We could not render the application shell. Please retry the request.</p>
            <button type="button" onClick={reset} style={{ padding: "0.75rem 1.25rem", cursor: "pointer" }}>Try again</button>
          </div>
        </main>
      </body>
    </html>
  );
}
