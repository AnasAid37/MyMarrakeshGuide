import { describe, expect, it } from "vitest";
import { validateEnvironment } from "./environment.js";

const validEnvironment = {
  NODE_ENV: "test",
  DATABASE_URL: "postgresql://user:password@localhost:5432/mmg",
  REDIS_URL: "redis://:password@localhost:6379/0",
  CORS_ORIGINS: "http://localhost:3000",
  COOKIE_SECURE: "false",
  COOKIE_SAME_SITE: "strict",
  CSRF_SECRET: "c".repeat(64),
  JWT_ACCESS_SECRET: "a".repeat(64),
  JWT_REFRESH_SECRET: "r".repeat(64),
};

describe("validateEnvironment", () => {
  it("parses a complete test environment", () => {
    const environment = validateEnvironment(validEnvironment);
    expect(environment.NODE_ENV).toBe("test");
    expect(environment.PORT).toBe(3001);
  });

  it("rejects insecure SameSite=None cookies", () => {
    expect(() =>
      validateEnvironment({
        ...validEnvironment,
        COOKIE_SAME_SITE: "none",
      }),
    ).toThrow("COOKIE_SECURE must be true");
  });
});
