import {
  ArgumentsHost,
  Catch,
  type ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from "@nestjs/common";
import type { Request, Response } from "express";

interface RequestWithId extends Request {
  id?: string;
}

interface NestErrorBody {
  error?: string;
  message?: string | string[];
  statusCode?: number;
}

const statusTitles: Record<number, string> = {
  400: "Bad Request",
  401: "Unauthorized",
  403: "Forbidden",
  404: "Not Found",
  405: "Method Not Allowed",
  409: "Conflict",
  413: "Payload Too Large",
  415: "Unsupported Media Type",
  422: "Unprocessable Entity",
  429: "Too Many Requests",
  500: "Internal Server Error",
  503: "Service Unavailable",
};

const statusCodes: Record<number, string> = {
  400: "BAD_REQUEST",
  401: "UNAUTHORIZED",
  403: "FORBIDDEN",
  404: "NOT_FOUND",
  405: "METHOD_NOT_ALLOWED",
  409: "CONFLICT",
  413: "PAYLOAD_TOO_LARGE",
  415: "UNSUPPORTED_MEDIA_TYPE",
  422: "UNPROCESSABLE_ENTITY",
  429: "RATE_LIMIT_EXCEEDED",
  500: "INTERNAL_SERVER_ERROR",
  503: "SERVICE_UNAVAILABLE",
};

@Catch()
export class ApiExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(ApiExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost): void {
    const context = host.switchToHttp();
    const request = context.getRequest<RequestWithId>();
    const response = context.getResponse<Response>();

    const isHttpException = exception instanceof HttpException;
    const status = isHttpException
      ? exception.getStatus()
      : HttpStatus.INTERNAL_SERVER_ERROR;
    const requestId = request.id ?? request.header("x-request-id") ?? "unavailable";
    const body = isHttpException ? exception.getResponse() : undefined;
    const parsedBody = typeof body === "object" && body !== null ? (body as NestErrorBody) : undefined;
    const messages = Array.isArray(parsedBody?.message) ? parsedBody.message : undefined;
    const title = statusTitles[status] ?? "Request Failed";
    const code = statusCodes[status] ?? "REQUEST_FAILED";
    const detail =
      status >= 500
        ? "The service could not complete the request."
        : typeof body === "string"
          ? body
          : typeof parsedBody?.message === "string"
            ? parsedBody.message
            : title;

    if (status >= 500) {
      const stack = exception instanceof Error ? exception.stack : undefined;
      this.logger.error(`Unhandled request failure requestId=${requestId}`, stack);
    }

    response.status(status).json({
      type: `https://api.mymarrakeshguide.com/problems/${code.toLowerCase().replaceAll("_", "-")}`,
      title,
      status,
      detail,
      instance: request.originalUrl,
      code,
      requestId,
      timestamp: new Date().toISOString(),
      ...(messages
        ? {
            errors: messages.map((message) => ({
              path: "request",
              message,
            })),
          }
        : {}),
    });
  }
}
