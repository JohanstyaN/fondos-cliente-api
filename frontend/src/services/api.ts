import axios from 'axios';
import { 
  FundTransactionRequest, 
  FundTransactionResponse, 
  TransactionHistoryModel 
} from '../types/funds';

const getApiUrl = (): string => {
  if (typeof window !== 'undefined' && (window as any).ENV?.REACT_APP_API_URL) {
    return (window as any).ENV.REACT_APP_API_URL;
  }
  
  return process.env.REACT_APP_API_URL || 'http://localhost:8000/api';
};

const API_BASE_URL = getApiUrl();

const log = {
  info: (message: string, data?: any) => {
    console.log(`[API INFO] ${message}`, data ? JSON.stringify(data, null, 2) : '');
  },
  error: (message: string, error?: any) => {
    console.error(`[API ERROR] ${message}`, error);
  },
  success: (message: string, data?: any) => {
    console.log(`[API SUCCESS] ${message}`, data ? JSON.stringify(data, null, 2) : '');
  }
};

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

api.interceptors.request.use(
  (config) => {
    log.info(`Request: ${config.method?.toUpperCase()} ${config.url}`, {
      baseURL: config.baseURL,
      headers: config.headers,
      data: config.data
    });
    return config;
  },
  (error) => {
    log.error('Request error:', error);
    return Promise.reject(error);
  }
);

api.interceptors.response.use(
  (response) => {
    log.success(`Response: ${response.status} ${response.config.method?.toUpperCase()} ${response.config.url}`, {
      status: response.status,
      data: response.data,
      headers: response.headers
    });
    return response;
  },
  (error) => {
    if (error.response) {
      log.error(`Response error: ${error.response.status} ${error.config?.method?.toUpperCase()} ${error.config?.url}`, {
        status: error.response.status,
        data: error.response.data,
        headers: error.response.headers
      });
    } else if (error.request) {
      log.error('Network error - no response received:', {
        request: error.request,
        config: error.config
      });
    } else {
      log.error('Request setup error:', error.message);
    }
    return Promise.reject(error);
  }
);

export const fundsApi = {
  healthCheck: async (): Promise<{ status: string }> => {
    try {
      log.info('Health check started');
      const response = await api.get('/v1/funds/health');
      log.success('Health check completed');
      return response.data;
    } catch (error) {
      log.error('Health check failed', error);
      throw error;
    }
  },

  subscribe: async (request: FundTransactionRequest): Promise<FundTransactionResponse> => {
    try {
      log.info('Subscribe request started', request);
      const response = await api.post('/v1/funds/subscribe', request);
      log.success('Subscribe completed successfully', response.data);
      return response.data;
    } catch (error) {
      log.error('Subscribe failed', error);
      throw error;
    }
  },

  cancel: async (request: FundTransactionRequest): Promise<FundTransactionResponse> => {
    try {
      log.info('Cancel request started', request);
      const response = await api.post('/v1/funds/cancel', request);
      log.success('Cancel completed successfully', response.data);
      return response.data;
    } catch (error) {
      log.error('Cancel failed', error);
      throw error;
    }
  },

  getHistory: async (): Promise<TransactionHistoryModel[]> => {
    try {
      log.info('Get history request started');
      const response = await api.get('/v1/funds/history');
      log.success('Get history completed successfully', response.data);
      return response.data;
    } catch (error) {
      log.error('Get history failed', error);
      throw error;
    }
  },
};

export default api;