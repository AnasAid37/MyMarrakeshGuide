import { describe, expect, it } from "vitest";
import { ProblemDetailsSchema } from "./problem-details.js";

describe("ProblemDetailsSchema", () => {
  it("accepts a valid problem response", () => {
    const result = ProblemDetailsSchema.safeParse({
      type: "https://api.mymarrakeshguide.com/problems/validation-error",
      title: "Validation failed",
      status: 400,
      detail: "The request body contains invalid fields.",
      instance: "/api/v1/trips",
      code: "VALIDATION_ERROR",
      requestId: "0198c104-b18f-7d1d-83f4-66eb61112f3a",
      timestamp: "2026-08-03T13:00:00.000Z",
      errors: [{ path: "budget", message: "Budget must be positive." }],
    });

    expect(result.success).toBe(true);
  });
});
