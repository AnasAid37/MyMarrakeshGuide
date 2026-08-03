import type { ConfigService } from "@nestjs/config";
import type { Response } from "express";
import { describe, expect, it, vi } from "vitest";
import { CsrfService } from "./csrf.service.js";

const values: Record<string, unknown> = {
  CSRF_SECRET: "s".repeat(64),
  COOKIE_SECURE: false,
  COOKIE_SAME_SITE: "strict",
  COOKIE_DOMAIN: "",
};

const configService = {
  get: (key: string) => values[key],
  getOrThrow: (key: string) => {
    const value = values[key];
    if (value === undefined) throw new Error(`Missing ${key}`);
    return value;
  },
} as ConfigService;

describe("CsrfService", () => {
  it("issues a signed token and secure cookie options", () => {
    const service = new CsrfService(configService);
    const cookie = vi.fn();
    const setHeader = vi.fn();
    const response = { cookie, setHeader } as unknown as Response;

    const token = service.issue(response);

    expect(token).toContain(".");
    expect(cookie).toHaveBeenCalledWith(
      "mmg.csrf",
      token,
      expect.objectContaining({ httpOnly: true, sameSite: "strict", path: "/" }),
    );
    expect(setHeader).toHaveBeenCalledWith("Cache-Control", "no-store");
  });
});
