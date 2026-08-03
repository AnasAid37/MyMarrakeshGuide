import { Injectable, type OnModuleDestroy, type OnModuleInit } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import Redis from "ioredis";

@Injectable()
export class RedisService implements OnModuleInit, OnModuleDestroy {
  private readonly client: Redis;

  constructor(configService: ConfigService) {
    const redisUrl = configService.getOrThrow<string>("REDIS_URL");

    this.client = new Redis(redisUrl, {
      lazyConnect: true,
      enableReadyCheck: true,
      maxRetriesPerRequest: 2,
      connectTimeout: 5_000,
      commandTimeout: 3_000,
      retryStrategy: (attempt) => Math.min(attempt * 250, 3_000),
    });
  }

  async onModuleInit(): Promise<void> {
    await this.client.connect();
  }

  async onModuleDestroy(): Promise<void> {
    await this.client.quit();
  }

  async ping(): Promise<void> {
    const response = await this.client.ping();
    if (response !== "PONG") {
      throw new Error("Redis returned an unexpected ping response.");
    }
  }

  get connection(): Redis {
    return this.client;
  }
}
