import "dotenv/config";
import { createPrismaClient } from "../src/client.js";

const databaseUrl = process.env.DATABASE_URL;

if (!databaseUrl) {
  throw new Error("DATABASE_URL is required for database seeding.");
}

const prisma = createPrismaClient(databaseUrl);

const categories = [
  { slug: "culture", name: "Culture", icon: "landmark", sortOrder: 10 },
  { slug: "food", name: "Food", icon: "utensils", sortOrder: 20 },
  { slug: "art-design", name: "Art & Design", icon: "palette", sortOrder: 30 },
  { slug: "nature", name: "Nature", icon: "trees", sortOrder: 40 },
  { slug: "shopping", name: "Shopping", icon: "shopping-bag", sortOrder: 50 },
  { slug: "wellness", name: "Wellness", icon: "sparkles", sortOrder: 60 },
  { slug: "adventure", name: "Adventure", icon: "compass", sortOrder: 70 },
  { slug: "family", name: "Family", icon: "users", sortOrder: 80 },
  { slug: "nightlife", name: "Nightlife", icon: "moon-star", sortOrder: 90 },
] as const;

const featureFlags = [
  {
    key: "traveler.itinerary-generation",
    description: "Enables the controlled itinerary generation workflow for approved cohorts.",
    enabled: false,
  },
  {
    key: "host.dashboard",
    description: "Enables the host dashboard for approved hospitality partners.",
    enabled: false,
  },
  {
    key: "traveler.premium",
    description: "Enables premium traveler entitlements after billing launch approval.",
    enabled: false,
  },
] as const;

async function main(): Promise<void> {
  await prisma.$transaction([
    ...categories.map((category) =>
      prisma.category.upsert({
        where: { slug: category.slug },
        update: {
          name: category.name,
          icon: category.icon,
          sortOrder: category.sortOrder,
          isActive: true,
        },
        create: category,
      }),
    ),
    ...featureFlags.map((flag) =>
      prisma.featureFlag.upsert({
        where: { key: flag.key },
        update: {
          description: flag.description,
        },
        create: {
          ...flag,
          type: "BOOLEAN",
          rules: {},
        },
      }),
    ),
  ]);
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (error: unknown) => {
    console.error("Database seed failed.", error);
    await prisma.$disconnect();
    process.exitCode = 1;
  });
