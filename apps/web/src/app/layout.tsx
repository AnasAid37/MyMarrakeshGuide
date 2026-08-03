import type { Metadata, Viewport } from "next";
import type { ReactNode } from "react";
import { QueryProvider } from "@/providers/query-provider";
import { getWebEnvironment } from "@/config/environment";
import "./globals.css";

const environment = getWebEnvironment();

export const metadata: Metadata = {
  metadataBase: new URL(environment.NEXT_PUBLIC_APP_URL),
  applicationName: "MyMarrakeshGuide",
  title: {
    default: "MyMarrakeshGuide | Your Marrakesh Journey, Perfectly Crafted",
    template: "%s | MyMarrakeshGuide",
  },
  description:
    "An AI-powered travel concierge that creates intelligent Marrakesh itineraries from verified local places.",
  category: "travel",
  alternates: { canonical: "/" },
  openGraph: {
    type: "website",
    locale: "en_US",
    siteName: "MyMarrakeshGuide",
    title: "Your Marrakesh journey, perfectly crafted",
    description: "Verified local intelligence, organized around the way you travel.",
    url: "/",
  },
  twitter: {
    card: "summary_large_image",
    title: "MyMarrakeshGuide",
    description: "Your Marrakesh journey, perfectly crafted.",
  },
  robots: { index: true, follow: true },
};

export const viewport: Viewport = {
  colorScheme: "light",
  themeColor: "#f6f2ea",
  width: "device-width",
  initialScale: 1,
};

export default function RootLayout({ children }: Readonly<{ children: ReactNode }>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body>
        <QueryProvider>{children}</QueryProvider>
      </body>
    </html>
  );
}
