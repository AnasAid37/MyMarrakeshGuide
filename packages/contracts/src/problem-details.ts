import { z } from "zod";

export const ProblemDetailsSchema = z.object({
  type: z.string().url(),
  title: z.string().min(1),
  status: z.number().int().min(400).max(599),
  detail: z.string().min(1),
  instance: z.string().min(1),
  code: z.string().regex(/^[A-Z][A-Z0-9_]*$/),
  requestId: z.string().min(8).max(128),
  timestamp: z.iso.datetime({ offset: true }),
  errors: z
    .array(
      z.object({
        path: z.string(),
        message: z.string(),
      }),
    )
    .optional(),
});

export type ProblemDetails = z.infer<typeof ProblemDetailsSchema>;
