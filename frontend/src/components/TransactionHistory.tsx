import React, { useState, useEffect } from 'react';
import { fundsApi } from '../services/api';
import { TransactionHistoryModel } from '../types/funds';

const TransactionHistory: React.FC = () => {
  const [transactions, setTransactions] = useState<TransactionHistoryModel[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchHistory();
  }, []);

  const fetchHistory = async () => {
    try {
      setLoading(true);
      const data = await fundsApi.getHistory();
      setTransactions(data);
      setError(null);
    } catch (error: any) {
      setError(error.response?.data?.detail || 'Error al cargar el historial');
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleString('es-ES');
  };

  const formatAmount = (amount: number) => {
    return new Intl.NumberFormat('es-ES', {
      style: 'currency',
      currency: 'USD'
    }).format(amount);
  };

  const getTransactionTypeColor = (type: string) => {
    return type === 'subscribe' ? 'success' : 'danger';
  };

  const getTransactionTypeText = (type: string) => {
    return type === 'subscribe' ? 'Suscripción' : 'Cancelación';
  };

  if (loading) {
    return (
      <div className="card">
        <h2 className="text-2xl mb-4">Historial de Transacciones</h2>
        <div className="loading">
          <div className="spinner"></div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="card">
        <h2 className="text-2xl mb-4">Historial de Transacciones</h2>
        <div className="message error">{error}</div>
        <button
          onClick={fetchHistory}
          className="btn btn-primary"
          style={{ width: '100%' }}
        >
          Reintentar
        </button>
      </div>
    );
  }

  return (
    <div className="card">
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>
        <h2 className="text-2xl">Historial de Transacciones</h2>
        <button
          onClick={fetchHistory}
          className="btn btn-secondary"
        >
          Actualizar
        </button>
      </div>
      
      {transactions.length === 0 ? (
        <div className="text-center py-8">
          No hay transacciones para mostrar
        </div>
      ) : (
        <div style={{ overflowX: 'auto' }}>
          <table className="table">
            <thead>
              <tr>
                <th>ID Transacción</th>
                <th>Usuario</th>
                <th>Fondo</th>
                <th>Tipo</th>
                <th>Monto</th>
                <th>Fecha</th>
                <th>Notificación</th>
              </tr>
            </thead>
            <tbody>
              {transactions.map((transaction) => (
                <tr key={transaction.transaction_id}>
                  <td>{transaction.transaction_id}</td>
                  <td>{transaction.user_id}</td>
                  <td>{transaction.id_fund}</td>
                  <td>
                    <span className={`badge ${getTransactionTypeColor(transaction.transaction_type)}`}>
                      {getTransactionTypeText(transaction.transaction_type)}
                    </span>
                  </td>
                  <td>{formatAmount(transaction.amount)}</td>
                  <td>{formatDate(transaction.timestamp)}</td>
                  <td>
                    <span className={`badge ${transaction.notification ? 'success' : 'info'}`}>
                      {transaction.notification ? 'Sí' : 'No'}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
};

export default TransactionHistory; 