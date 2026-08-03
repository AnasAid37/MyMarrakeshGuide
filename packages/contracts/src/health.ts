import { z } from "zod";

export const DependencyHealthSchema = z.object({
  status: z.enum(["up", "down"]),
  latencyMs: z.number().nonnegative(),
  message: z.string().optional(),
});

export const HealthResponseSchema = z.object({
  status: z.enum(["ok", "degraded"]),
  service: z.string().min(1),
  version: z.string().min(1),
  timestamp: z.iso.datetime({ offset: true }),
  uptimeSeconds: z.number().nonnegative(),
  dependencies: z.record(z.string(), DependencyHealthSchema).optional(),
});

export type DependencyHealth = z.infer<typeof DependencyHealthSchema>;
export type HealthResponse = z.infer<typeof HealthResponseSchema>;
