import type { MetadataRoute } from "next";
import { getWebEnvironment } from "@/config/environment";

export default function sitemap(): MetadataRoute.Sitemap {
  const { NEXT_PUBLIC_APP_URL } = getWebEnvironment();
  return [
    {
      url: NEXT_PUBLIC_APP_URL,
      lastModified: new Date(),
      changeFrequency: "weekly",
      priority: 1,
    },
  ];
}
