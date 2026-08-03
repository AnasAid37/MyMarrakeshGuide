import type { ConfigService } from "@nestjs/config";
import type { PrismaService } from "@mmg/database";
import { describe, expect, it, vi } from "vitest";
import type { RedisService } from "../infrastructure/cache/redis.service.js";
import { HealthService } from "./health.service.js";

const config = {
  getOrThrow: (key: string) => (key === "APP_NAME" ? "MyMarrakeshGuide API" : "0.1.0"),
} as ConfigService;

describe("HealthService", () => {
  it("reports readiness when PostgreSQL and Redis respond", async () => {
    const prisma = { ping: vi.fn().mockResolvedValue(undefined) } as unknown as PrismaService;
    const redis = { ping: vi.fn().mockResolvedValue(undefined) } as unknown as RedisService;
    const service = new HealthService(config, prisma, redis);

    const result = await service.readiness();

    expect(result.status).toBe("ok");
    expect(result.dependencies?.database.status).toBe("up");
    expect(result.dependencies?.redis.status).toBe("up");
  });

  it("reports degraded readiness when a dependency fails", async () => {
    const prisma = { ping: vi.fn().mockRejectedValue(new Error("database unavailable")) } as unknown as PrismaService;
    const redis = { ping: vi.fn().mockResolvedValue(undefined) } as unknown as RedisService;
    const service = new HealthService(config, prisma, redis);

    const result = await service.readiness();

    expect(result.status).toBe("degraded");
    expect(result.dependencies?.database.status).toBe("down");
  });
});
