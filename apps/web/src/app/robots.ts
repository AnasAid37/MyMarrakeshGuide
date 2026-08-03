import type { MetadataRoute } from "next";
import { getWebEnvironment } from "@/config/environment";

export default function robots(): MetadataRoute.Robots {
  const { NEXT_PUBLIC_APP_URL } = getWebEnvironment();
  return {
    rules: [
      {
        userAgent: "*",
        allow: "/",
        disallow: ["/account/", "/admin/", "/host/", "/trips/", "/api/"],
      },
    ],
    sitemap: `${NEXT_PUBLIC_APP_URL}/sitemap.xml`,
    host: NEXT_PUBLIC_APP_URL,
  };
}
