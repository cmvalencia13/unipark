import { auth } from "./auth";

const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8080";

export async function serverFetch<T>(path: string, options?: RequestInit): Promise<T> {
  const session = await auth();
  const res = await fetch(`${API_URL}${path}`, {
    ...options,
    headers: {
      "Content-Type": "application/json",
      ...(session?.user ? { Authorization: `Bearer ${(session as any).accessToken}` } : {}),
      ...options?.headers,
    },
  });

  if (!res.ok) {
    if (res.status === 403) throw new ForbiddenError();
    throw new ApiError(res.status, await res.text());
  }
  return res.json();
}

export class ApiError extends Error {
  constructor(public status: number, message: string) {
    super(message);
  }
}

export class ForbiddenError extends ApiError {
  constructor() {
    super(403, "Forbidden");
  }
}

export async function clientFetch<T>(path: string, options?: RequestInit): Promise<T> {
  const res = await fetch(`${API_URL}${path}`, {
    ...options,
    headers: {
      "Content-Type": "application/json",
      ...options?.headers,
    },
    credentials: "include",
  });

  if (!res.ok) {
    if (res.status === 403) throw new ForbiddenError();
    throw new ApiError(res.status, await res.text());
  }
  return res.json();
}
