import { afterEach, describe, expect, it, vi } from "vitest";
import { ApiClientError, apiRequest } from "./api-client";

afterEach(() => {
  vi.unstubAllGlobals();
});

describe("apiRequest", () => {
  it("returns parsed JSON for a successful response", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue(new Response(JSON.stringify({ ok: true }))));
    await expect(apiRequest<{ ok: boolean }>("/system")).resolves.toEqual({ ok: true });
  });

  it("surfaces safe problem details for failed responses", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue(
        new Response(JSON.stringify({ detail: "Request denied." }), {
          status: 403,
          headers: { "x-request-id": "request-123" },
        }),
      ),
    );

    await expect(apiRequest("/private")).rejects.toEqual(
      new ApiClientError("Request denied.", 403, "request-123"),
    );
  });
});
