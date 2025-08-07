import React, { useState } from 'react';
import { fundsApi } from '../services/api';
import { FundTransactionRequest, FundTransactionResponse } from '../types/funds';

interface CancelFormProps {
  onSuccess: (response: FundTransactionResponse) => void;
  onError: (error: string) => void;
}

const CancelForm: React.FC<CancelFormProps> = ({ onSuccess, onError }) => {
  const [formData, setFormData] = useState<FundTransactionRequest>({
    user_id: '',
    id_fund: '',
    transaction_type: 'cancel'
  });
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      const response = await fundsApi.cancel(formData);
      onSuccess(response);
      setFormData({
        user_id: '',
        id_fund: '',
        transaction_type: 'cancel'
      });
    } catch (error: any) {
      onError(error.response?.data?.detail || 'Error al cancelar la suscripción');
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  return (
    <div className="card">
      <h2 className="text-2xl mb-4">Cancelar Suscripción</h2>
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

        <button
          type="submit"
          disabled={loading}
          className="btn btn-danger"
          style={{ width: '100%' }}
        >
          {loading ? 'Cancelando...' : 'Cancelar Suscripción'}
        </button>
      </form>
    </div>
  );
};

export default CancelForm; 