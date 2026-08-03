import { getWebEnvironment } from "@/config/environment";

export class ApiClientError extends Error {
  constructor(
    message: string,
    readonly status: number,
    readonly requestId: string | null,
  ) {
    super(message);
    this.name = "ApiClientError";
  }
}

export async function apiRequest<T>(
  path: `/${string}`,
  init: RequestInit = {},
): Promise<T> {
  const { NEXT_PUBLIC_API_URL } = getWebEnvironment();
  const response = await fetch(`${NEXT_PUBLIC_API_URL}${path}`, {
    ...init,
    credentials: "include",
    headers: {
      accept: "application/json",
      ...init.headers,
    },
  });

  if (!response.ok) {
    let detail = `API request failed with status ${response.status}.`;
    try {
      const problem = (await response.json()) as { detail?: string };
      detail = problem.detail ?? detail;
    } catch {
      // Preserve the safe status-based detail when a response is not JSON.
    }
    throw new ApiClientError(detail, response.status, response.headers.get("x-request-id"));
  }

  return (await response.json()) as T;
}
