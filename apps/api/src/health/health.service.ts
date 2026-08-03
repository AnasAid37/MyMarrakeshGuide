import { Injectable } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import type { DependencyHealth, HealthResponse } from "@mmg/contracts";
import { PrismaService } from "@mmg/database";
import { RedisService } from "../infrastructure/cache/redis.service.js";

@Injectable()
export class HealthService {
  constructor(
    private readonly configService: ConfigService,
    private readonly prisma: PrismaService,
    private readonly redis: RedisService,
  ) {}

  liveness(): HealthResponse {
    return this.response("ok");
  }

  async readiness(): Promise<HealthResponse> {
    const [database, redis] = await Promise.all([
      this.checkDependency(() => this.prisma.ping()),
      this.checkDependency(() => this.redis.ping()),
    ]);

    const dependencies = { database, redis };
    const status = Object.values(dependencies).every((dependency) => dependency.status === "up")
      ? "ok"
      : "degraded";

    return this.response(status, dependencies);
  }

  private response(
    status: "ok" | "degraded",
    dependencies?: Record<string, DependencyHealth>,
  ): HealthResponse {
    return {
      status,
      service: this.configService.getOrThrow<string>("APP_NAME"),
      version: this.configService.getOrThrow<string>("APP_VERSION"),
      timestamp: new Date().toISOString(),
      uptimeSeconds: process.uptime(),
      ...(dependencies ? { dependencies } : {}),
    };
  }

  private async checkDependency(operation: () => Promise<void>): Promise<DependencyHealth> {
    const startedAt = performance.now();

    try {
      await Promise.race([
        operation(),
        new Promise<never>((_, reject) =>
          setTimeout(() => reject(new Error("Dependency health check timed out.")), 2_500),
        ),
      ]);
      return { status: "up", latencyMs: Math.round(performance.now() - startedAt) };
    } catch (error: unknown) {
      return {
        status: "down",
        latencyMs: Math.round(performance.now() - startedAt),
        message: error instanceof Error ? error.message : "Dependency check failed.",
      };
    }
  }
}
