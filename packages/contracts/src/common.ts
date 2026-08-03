import { z } from "zod";

export const UuidSchema = z.uuid();
export const IsoDateTimeSchema = z.iso.datetime({ offset: true });

export const RequestMetadataSchema = z.object({
  requestId: z.string().min(8).max(128),
  timestamp: IsoDateTimeSchema,
});

export const PaginationQuerySchema = z.object({
  cursor: z.string().min(1).max(512).optional(),
  limit: z.coerce.number().int().min(1).max(100).default(20),
});

export const PageInfoSchema = z.object({
  nextCursor: z.string().nullable(),
  hasNextPage: z.boolean(),
});

export type PaginationQuery = z.infer<typeof PaginationQuerySchema>;
export type PageInfo = z.infer<typeof PageInfoSchema>;
