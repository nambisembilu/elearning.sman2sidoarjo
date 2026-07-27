const API_URL = import.meta.env.VITE_API_URL || "http://localhost:4000/api";

export function getStoredSession() {
  try {
    return JSON.parse(localStorage.getItem("elearning-session") || "null");
  } catch {
    return null;
  }
}

export function storeSession(session) {
  localStorage.setItem("elearning-session", JSON.stringify(session));
}

export function clearSession() {
  localStorage.removeItem("elearning-session");
}

export async function apiFetch(path, options = {}) {
  const session = getStoredSession();
  const headers = new Headers(options.headers || {});
  const isForm = options.body instanceof FormData;
  if (!isForm && options.body !== undefined) {
    headers.set("Content-Type", "application/json");
  }
  if (session?.token) headers.set("Authorization", `Bearer ${session.token}`);

  const response = await fetch(`${API_URL}${path}`, {
    ...options,
    headers,
    body:
      !isForm && options.body !== undefined
        ? JSON.stringify(options.body)
        : options.body,
  });

  const contentType = response.headers.get("content-type") || "";
  const data = contentType.includes("application/json")
    ? await response.json()
    : await response.text();

  if (!response.ok) {
    const message = data?.message || data?.detail || "Request gagal";
    throw new Error(message);
  }

  return data;
}

export function withQuery(path, query = {}) {
  const params = new URLSearchParams();
  Object.entries(query).forEach(([key, value]) => {
    if (value !== undefined && value !== null && value !== "") {
      params.set(key, value);
    }
  });
  const qs = params.toString();
  return qs ? `${path}?${qs}` : path;
}

export { API_URL };
