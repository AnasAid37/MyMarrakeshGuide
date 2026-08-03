import "reflect-metadata";
import { NestFactory } from "@nestjs/core";
import { ConfigService } from "@nestjs/config";
import { Logger } from "nestjs-pino";
import { DocumentBuilder, SwaggerModule } from "@nestjs/swagger";
import { ValidationPipe, VersioningType } from "@nestjs/common";
import cookieParser from "cookie-parser";
import compression from "compression";
import express from "express";
import helmet from "helmet";
import { AppModule } from "./app.module.js";
import { CsrfService } from "./security/csrf.service.js";

async function bootstrap(): Promise<void> {
  const app = await NestFactory.create(AppModule, {
    bufferLogs: true,
    bodyParser: false,
  });
  const configService = app.get(ConfigService);
  const logger = app.get(Logger);
  const nodeEnvironment = configService.getOrThrow<string>("NODE_ENV");
  const apiPrefix = configService.getOrThrow<string>("API_PREFIX");
  const apiVersion = String(configService.getOrThrow<number>("API_VERSION"));
  const port = configService.getOrThrow<number>("PORT");
  const corsOrigins = configService
    .getOrThrow<string>("CORS_ORIGINS")
    .split(",")
    .map((origin) => origin.trim())
    .filter(Boolean);

  app.useLogger(logger);
  app.enableShutdownHooks();
  app.setGlobalPrefix(apiPrefix);
  app.enableVersioning({
    type: VersioningType.URI,
    defaultVersion: apiVersion,
  });

  const expressApp = app.getHttpAdapter().getInstance();
  expressApp.disable("x-powered-by");
  expressApp.set("trust proxy", configService.getOrThrow<boolean>("TRUST_PROXY"));

  app.use(
    helmet({
      contentSecurityPolicy: false,
      crossOriginEmbedderPolicy: false,
      crossOriginResourcePolicy: { policy: "cross-origin" },
      referrerPolicy: { policy: "no-referrer" },
      strictTransportSecurity:
        nodeEnvironment === "production"
          ? { maxAge: 63_072_000, includeSubDomains: true, preload: true }
          : false,
    }),
  );
  app.use(compression({ threshold: 1_024 }));
  app.use(express.json({ limit: "1mb", strict: true }));
  app.use(express.urlencoded({ extended: false, limit: "64kb" }));
  app.use(cookieParser());
  app.use(app.get(CsrfService).middleware());

  app.enableCors({
    origin(origin, callback) {
      if (!origin || corsOrigins.includes(origin)) {
        callback(null, true);
        return;
      }
      callback(new Error("Origin is not allowed by CORS."), false);
    },
    credentials: true,
    methods: ["GET", "HEAD", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allowedHeaders: ["accept", "authorization", "content-type", "x-csrf-token", "x-request-id"],
    exposedHeaders: ["x-request-id", "ratelimit-limit", "ratelimit-remaining", "ratelimit-reset"],
    maxAge: 600,
  });

  app.useGlobalPipes(
    new ValidationPipe({
      transform: true,
      whitelist: true,
      forbidNonWhitelisted: true,
      forbidUnknownValues: true,
      stopAtFirstError: false,
      validationError: { target: false, value: false },
    }),
  );

  if (configService.getOrThrow<boolean>("SWAGGER_ENABLED")) {
    const documentConfig = new DocumentBuilder()
      .setTitle("MyMarrakeshGuide API")
      .setDescription("Versioned REST API for the traveler concierge and hospitality SaaS platform.")
      .setVersion(configService.getOrThrow<string>("APP_VERSION"))
      .addBearerAuth(
        { type: "http", scheme: "bearer", bearerFormat: "JWT" },
        "access-token",
      )
      .addCookieAuth("mmg.refresh", { type: "apiKey", in: "cookie" }, "refresh-token")
      .build();
    const document = SwaggerModule.createDocument(app, documentConfig);
    SwaggerModule.setup(`${apiPrefix}/docs`, app, document, {
      jsonDocumentUrl: `${apiPrefix}/docs/openapi.json`,
      customSiteTitle: "MyMarrakeshGuide API",
      swaggerOptions: {
        persistAuthorization: false,
        displayRequestDuration: true,
        filter: true,
      },
    });
  }

  await app.listen(port, "0.0.0.0");
  logger.log(`API listening on http://0.0.0.0:${port}/${apiPrefix}/v${apiVersion}`);
}

bootstrap().catch((error: unknown) => {
  console.error("Fatal API bootstrap failure.", error);
  process.exit(1);
});
