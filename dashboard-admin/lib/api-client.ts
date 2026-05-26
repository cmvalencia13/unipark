import axios, { AxiosInstance } from 'axios';
import { getSession } from 'next-auth/react';

const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL || 'https://api.unipark.local/v1';

let apiClient: AxiosInstance | null = null;

export const createApiClient = (accessToken?: string): AxiosInstance => {
  return axios.create({
    baseURL: API_BASE_URL,
    headers: {
      'Content-Type': 'application/json',
      ...(accessToken && { Authorization: `Bearer ${accessToken}` }),
    },
  });
};

export const getApiClient = async (): Promise<AxiosInstance> => {
  const session = await getSession();
  const token = session?.accessToken;
  return createApiClient(token);
};

// Singleton instance for server-side usage
export const apiClient = (): AxiosInstance => {
  if (!apiClient) {
    apiClient = createApiClient();
  }
  return apiClient;
};

// API methods
export const api = {
  // Lots
  getLots: async () => {
    const client = await getApiClient();
    return client.get('/lots');
  },

  getLotById: async (id: string) => {
    const client = await getApiClient();
    return client.get(`/lots/${id}`);
  },

  // Violations
  getViolations: async (status?: string) => {
    const client = await getApiClient();
    return client.get('/violations', { params: { status } });
  },

  updateViolation: async (id: string, data: { status: string }) => {
    const client = await getApiClient();
    return client.patch(`/violations/${id}`, data);
  },

  // Me
  getMe: async () => {
    const client = await getApiClient();
    return client.get('/me');
  },

  // Audit
  getAuditLogs: async (from?: string, to?: string) => {
    const client = await getApiClient();
    return client.get('/audit', { params: { from, to } });
  },
};
