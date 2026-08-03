import { randomUUID } from "node:crypto";
import { Module } from "@nestjs/common";
import { ConfigModule, ConfigService } from "@nestjs/config";
import { APP_FILTER, APP_GUARD } from "@nestjs/core";
import { ThrottlerGuard, ThrottlerModule } from "@nestjs/throttler";
import { LoggerModule } from "nestjs-pino";
import { PrismaModule } from "@mmg/database";
import { ApiExceptionFilter } from "./common/errors/api-exception.filter.js";
import { validateEnvironment } from "./config/environment.js";
import { HealthModule } from "./health/health.module.js";
import { RedisModule } from "./infrastructure/cache/redis.module.js";
import { SecurityModule } from "./security/security.module.js";
import { SystemModule } from "./system/system.module.js";

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      cache: true,
      expandVariables: false,
      envFilePath: [".env", "../../.env"],
      validate: validateEnvironment,
    }),
    LoggerModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        pinoHttp: {
          level: configService.getOrThrow<string>("LOG_LEVEL"),
          autoLogging: {
            ignore: (request) => request.url?.includes("/health/live") ?? false,
          },
          genReqId: (request, response) => {
            const supplied = request.headers["x-request-id"];
            const requestId =
              typeof supplied === "string" && supplied.length >= 8
                ? supplied.slice(0, 128)
                : randomUUID();
            response.setHeader("x-request-id", requestId);
            return requestId;
          },
          redact: {
            paths: [
              "req.headers.authorization",
              "req.headers.cookie",
              "req.headers['x-csrf-token']",
              "res.headers['set-cookie']",
              "password",
              "passwordHash",
              "accessToken",
              "refreshToken",
              "token",
              "apiKey",
              "secret",
            ],
            censor: "[REDACTED]",
          },
          transport:
            configService.getOrThrow<string>("NODE_ENV") === "development"
              ? {
                  target: "pino-pretty",
                  options: { colorize: true, singleLine: true, translateTime: "SYS:standard" },
                }
              : undefined,
        },
      }),
    }),
    ThrottlerModule.forRoot([
      {
        name: "default",
        ttl: 60_000,
        limit: 100,
      },
    ]),
    PrismaModule,
    RedisModule,
    SecurityModule,
    HealthModule,
    SystemModule,
  ],
  providers: [
    { provide: APP_GUARD, useClass: ThrottlerGuard },
    { provide: APP_FILTER, useClass: ApiExceptionFilter },
  ],
})
export class AppModule {}
