import { z } from "zod";

const booleanFromString = z
  .enum(["true", "false"])
  .transform((value) => value === "true");

const sameSiteSchema = z.enum(["strict", "lax", "none"]);

const providerSchema = (keyName: string) =>
  z
    .object({
      enabled: z.boolean().default(false),
      key: z.string().optional(),
    })
    .superRefine((value, context) => {
      if (value.enabled && !value.key) {
        context.addIssue({
          code: "custom",
          path: ["key"],
          message: `${keyName} is required when the provider is enabled.`,
        });
      }
    });

const rawEnvironmentSchema = z.object({
  NODE_ENV: z.enum(["development", "test", "production"]).default("development"),
  APP_NAME: z.string().min(1).max(100).default("MyMarrakeshGuide API"),
  APP_VERSION: z.string().min(1).max(40).default("0.1.0"),
  PORT: z.coerce.number().int().min(1).max(65_535).default(3001),
  API_PREFIX: z.string().regex(/^[a-z][a-z0-9-]*$/).default("api"),
  API_VERSION: z.coerce.number().int().min(1).max(99).default(1),
  LOG_LEVEL: z.enum(["silent", "fatal", "error", "warn", "info", "debug", "trace"]).default("info"),
  TRUST_PROXY: booleanFromString.default(false),
  SWAGGER_ENABLED: booleanFromString.default(false),
  DATABASE_URL: z.string().url().startsWith("postgresql://"),
  DATABASE_POOL_MAX: z.coerce.number().int().min(2).max(100).default(20),
  REDIS_URL: z.string().url().startsWith("redis://"),
  CORS_ORIGINS: z.string().min(1),
  COOKIE_DOMAIN: z.string().optional(),
  COOKIE_SECURE: booleanFromString.default(true),
  COOKIE_SAME_SITE: sameSiteSchema.default("lax"),
  CSRF_SECRET: z.string().min(48),
  JWT_ACCESS_SECRET: z.string().min(48),
  JWT_REFRESH_SECRET: z.string().min(48),
  JWT_ACCESS_TTL_SECONDS: z.coerce.number().int().min(60).max(3600).default(900),
  JWT_REFRESH_TTL_SECONDS: z.coerce.number().int().min(3600).max(7_776_000).default(2_592_000),
  OPENAI_ENABLED: booleanFromString.default(false),
  OPENAI_API_KEY: z.string().optional(),
  GOOGLE_MAPS_ENABLED: booleanFromString.default(false),
  GOOGLE_MAPS_API_KEY: z.string().optional(),
  STRIPE_ENABLED: booleanFromString.default(false),
  STRIPE_SECRET_KEY: z.string().optional(),
  STRIPE_WEBHOOK_SECRET: z.string().optional(),
  CLOUDINARY_ENABLED: booleanFromString.default(false),
  CLOUDINARY_API_SECRET: z.string().optional(),
  POSTHOG_ENABLED: booleanFromString.default(false),
  POSTHOG_API_KEY: z.string().optional(),
  SENTRY_ENABLED: booleanFromString.default(false),
  SENTRY_DSN: z.string().optional(),
});

export type Environment = z.infer<typeof rawEnvironmentSchema>;

export function validateEnvironment(input: Record<string, unknown>): Environment {
  const environment = rawEnvironmentSchema.parse(input);

  providerSchema("OPENAI_API_KEY").parse({
    enabled: environment.OPENAI_ENABLED,
    key: environment.OPENAI_API_KEY,
  });
  providerSchema("GOOGLE_MAPS_API_KEY").parse({
    enabled: environment.GOOGLE_MAPS_ENABLED,
    key: environment.GOOGLE_MAPS_API_KEY,
  });
  providerSchema("POSTHOG_API_KEY").parse({
    enabled: environment.POSTHOG_ENABLED,
    key: environment.POSTHOG_API_KEY,
  });
  providerSchema("SENTRY_DSN").parse({
    enabled: environment.SENTRY_ENABLED,
    key: environment.SENTRY_DSN,
  });

  if (environment.COOKIE_SAME_SITE === "none" && !environment.COOKIE_SECURE) {
    throw new Error("COOKIE_SECURE must be true when COOKIE_SAME_SITE is none.");
  }

  if (environment.NODE_ENV === "production" && !environment.COOKIE_SECURE) {
    throw new Error("COOKIE_SECURE must be true in production.");
  }

  if (environment.STRIPE_ENABLED) {
    if (!environment.STRIPE_SECRET_KEY || !environment.STRIPE_WEBHOOK_SECRET) {
      throw new Error(
        "STRIPE_SECRET_KEY and STRIPE_WEBHOOK_SECRET are required when Stripe is enabled.",
      );
    }
  }

  return environment;
}
