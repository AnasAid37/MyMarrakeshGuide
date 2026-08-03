import { INestApplication, VersioningType } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { Test } from "@nestjs/testing";
import request from "supertest";
import { afterEach, beforeEach, describe, expect, it } from "vitest";
import { SystemController } from "../src/system/system.controller.js";

const configService = {
  getOrThrow: (key: string) => (key === "APP_NAME" ? "MyMarrakeshGuide API" : "0.1.0"),
};

describe("SystemController (e2e)", () => {
  let app: INestApplication;

  beforeEach(async () => {
    const moduleRef = await Test.createTestingModule({
      controllers: [SystemController],
      providers: [{ provide: ConfigService, useValue: configService }],
    }).compile();

    app = moduleRef.createNestApplication();
    app.setGlobalPrefix("api");
    app.enableVersioning({ type: VersioningType.URI, defaultVersion: "1" });
    await app.init();
  });

  afterEach(async () => {
    await app.close();
  });

  it("GET /api/v1 returns operational service metadata", async () => {
    const response = await request(app.getHttpServer()).get("/api/v1").expect(200);
    expect(response.body).toEqual({
      name: "MyMarrakeshGuide API",
      version: "0.1.0",
      status: "operational",
    });
  });
});
