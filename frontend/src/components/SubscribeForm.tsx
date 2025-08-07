import React, { useState } from 'react';
import { fundsApi } from '../services/api';
import { FundTransactionRequest, FundTransactionResponse } from '../types/funds';

interface SubscribeFormProps {
  onSuccess: (response: FundTransactionResponse) => void;
  onError: (error: string) => void;
}

// Logger function
const log = {
  info: (message: string, data?: any) => {
    console.log(`🔵 [SubscribeForm] ${message}`, data ? JSON.stringify(data, null, 2) : '');
  },
  error: (message: string, error?: any) => {
    console.error(`🔴 [SubscribeForm] ${message}`, error);
  },
  success: (message: string, data?: any) => {
    console.log(`🟢 [SubscribeForm] ${message}`, data ? JSON.stringify(data, null, 2) : '');
  }
};

const SubscribeForm: React.FC<SubscribeFormProps> = ({ onSuccess, onError }) => {
  const [formData, setFormData] = useState<FundTransactionRequest>({
    user_id: '',
    id_fund: '',
    transaction_type: 'subscribe',
    notification_type: 'email'
  });
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    log.info('Form submitted', formData);
    setLoading(true);

    try {
      log.info('Starting subscription request');
      const response = await fundsApi.subscribe(formData);
      log.success('Subscription successful', response);
      onSuccess(response);
      setFormData({
        user_id: '',
        id_fund: '',
        transaction_type: 'subscribe',
        notification_type: 'email'
      });
      log.info('Form reset after successful subscription');
    } catch (error: any) {
      log.error('Subscription failed', {
        error: error,
        response: error.response,
        message: error.message,
        status: error.response?.status,
        data: error.response?.data
      });
      const errorMessage = error.response?.data?.detail || 'Error al suscribirse al fondo';
      log.error('Error message to user:', errorMessage);
      onError(errorMessage);
    } finally {
      setLoading(false);
      log.info('Loading state set to false');
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    log.info(`Form field changed: ${name} = ${value}`);
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  return (
    <div className="card">
      <h2 className="text-2xl mb-4">Suscribirse a un Fondo</h2>
      <form onSubmit={handleSubmit}>
        <div className="form-group">
          <label htmlFor="user_id">
            ID de Usuario
          </label>
          <input
            type="text"
            id="user_id"
            name="user_id"
            value={formData.user_id}
            onChange={handleChange}
            required
            placeholder="Ej: user123"
          />
        </div>

        <div className="form-group">
          <label htmlFor="id_fund">
            ID del Fondo
          </label>
          <input
            type="text"
            id="id_fund"
            name="id_fund"
            value={formData.id_fund}
            onChange={handleChange}
            required
            placeholder="Ej: fondo456"
          />
        </div>

        <div className="form-group">
          <label htmlFor="notification_type">
            Tipo de Notificación
          </label>
          <select
            id="notification_type"
            name="notification_type"
            value={formData.notification_type}
            onChange={handleChange}
          >
            <option value="email">Email</option>
            <option value="sms">SMS</option>
          </select>
        </div>

        <button
          type="submit"
          disabled={loading}
          className="btn btn-primary"
          style={{ width: '100%' }}
        >
          {loading ? 'Suscribiendo...' : 'Suscribirse'}
        </button>
      </form>
    </div>
  );
};

export default SubscribeForm; 