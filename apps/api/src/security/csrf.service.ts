import { createHmac, randomBytes, timingSafeEqual } from "node:crypto";
import { Injectable } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import type { NextFunction, Request, RequestHandler, Response } from "express";

const SAFE_METHODS = new Set(["GET", "HEAD", "OPTIONS"]);

@Injectable()
export class CsrfService {
  private readonly secret: string;
  private readonly secure: boolean;
  private readonly sameSite: "strict" | "lax" | "none";
  private readonly domain: string | undefined;
  private readonly cookieName: string;

  constructor(private readonly configService: ConfigService) {
    this.secret = configService.getOrThrow<string>("CSRF_SECRET");
    this.secure = configService.getOrThrow<boolean>("COOKIE_SECURE");
    this.sameSite = configService.getOrThrow<"strict" | "lax" | "none">("COOKIE_SAME_SITE");
    this.domain = configService.get<string>("COOKIE_DOMAIN") || undefined;
    this.cookieName = this.secure ? "__Host-mmg.csrf" : "mmg.csrf";
  }

  issue(response: Response): string {
    const token = this.generateToken();

    response.cookie(this.cookieName, token, {
      httpOnly: true,
      secure: this.secure,
      sameSite: this.sameSite,
      path: "/",
      ...(this.domain && !this.cookieName.startsWith("__Host-") ? { domain: this.domain } : {}),
      maxAge: 2 * 60 * 60 * 1000,
    });

    response.setHeader("Cache-Control", "no-store");
    return token;
  }

  middleware(): RequestHandler {
    return (request: Request, response: Response, next: NextFunction): void => {
      if (SAFE_METHODS.has(request.method)) {
        next();
        return;
      }

      const cookieToken = request.cookies?.[this.cookieName] as string | undefined;
      const headerToken = request.header("x-csrf-token");

      if (
        !cookieToken ||
        !headerToken ||
        cookieToken !== headerToken ||
        !this.verifyToken(headerToken)
      ) {
        response.status(403).json({
          type: "https://api.mymarrakeshguide.com/problems/csrf-validation-failed",
          title: "Forbidden",
          status: 403,
          detail: "A valid CSRF token is required for this request.",
          instance: request.originalUrl,
          code: "CSRF_VALIDATION_FAILED",
          requestId: request.header("x-request-id") ?? "unavailable",
          timestamp: new Date().toISOString(),
        });
        return;
      }

      next();
    };
  }

  private generateToken(): string {
    const nonce = randomBytes(32).toString("base64url");
    const signature = this.sign(nonce);
    return `${nonce}.${signature}`;
  }

  private verifyToken(token: string): boolean {
    const separator = token.lastIndexOf(".");
    if (separator <= 0) {
      return false;
    }

    const nonce = token.slice(0, separator);
    const providedSignature = token.slice(separator + 1);
    const expectedSignature = this.sign(nonce);
    const provided = Buffer.from(providedSignature);
    const expected = Buffer.from(expectedSignature);

    return provided.length === expected.length && timingSafeEqual(provided, expected);
  }

  private sign(nonce: string): string {
    return createHmac("sha256", this.secret).update(nonce).digest("base64url");
  }
}
