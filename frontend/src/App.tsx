import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';
import SubscribeForm from './components/SubscribeForm';
import CancelForm from './components/CancelForm';
import TransactionHistory from './components/TransactionHistory';
import { FundTransactionResponse } from './types/funds';

const log = {
  info: (message: string, data?: any) => {
    console.log(`🔵 [App] ${message}`, data ? JSON.stringify(data, null, 2) : '');
  },
  error: (message: string, error?: any) => {
    console.error(`🔴 [App] ${message}`, error);
  },
  success: (message: string, data?: any) => {
    console.log(`🟢 [App] ${message}`, data ? JSON.stringify(data, null, 2) : '');
  }
};

function App() {
  const [message, setMessage] = useState<{ text: string; type: 'success' | 'error' } | null>(null);

  useEffect(() => {
    log.info('App component mounted');
    log.info('Environment variables:', {
      NODE_ENV: process.env.NODE_ENV,
      REACT_APP_API_URL: process.env.REACT_APP_API_URL
    });
  }, []);

  const handleSuccess = (response: FundTransactionResponse) => {
    log.success('Transaction successful', response);
    setMessage({
      text: `Transacción exitosa! ID: ${response.transaction_id}, Nuevo balance: $${response.new_balance}`,
      type: 'success'
    });
    setTimeout(() => {
      log.info('Clearing success message');
      setMessage(null);
    }, 5000);
  };

  const handleError = (error: string) => {
    log.error('Transaction error', error);
    setMessage({
      text: error,
      type: 'error'
    });
    setTimeout(() => {
      log.info('Clearing error message');
      setMessage(null);
    }, 5000);
  };

  return (
    <Router>
      <div>
        {/* Header */}
        <header className="header">
          <div className="container">
            <div className="header-content">
              <h1 className="text-3xl">
                Gestión de Fondos
              </h1>
              <nav className="nav">
                <Link to="/">Inicio</Link>
                <Link to="/subscribe">Suscribirse</Link>
                <Link to="/cancel">Cancelar</Link>
                <Link to="/history">Historial</Link>
              </nav>
            </div>
          </div>
        </header>

        {/* Message */}
        {message && (
          <div className="container">
            <div className={`message ${message.type}`}>
              {message.text}
            </div>
          </div>
        )}

        {/* Main Content */}
        <main className="main">
          <div className="container">
            <Routes>
              <Route path="/" element={<Home />} />
              <Route 
                path="/subscribe" 
                element={<SubscribeForm onSuccess={handleSuccess} onError={handleError} />} 
              />
              <Route 
                path="/cancel" 
                element={<CancelForm onSuccess={handleSuccess} onError={handleError} />} 
              />
              <Route path="/history" element={<TransactionHistory />} />
            </Routes>
          </div>
        </main>
      </div>
    </Router>
  );
}

// Home component
const Home: React.FC = () => {
  return (
    <div className="text-center">
      <h2 className="text-4xl mb-8">
        Bienvenido al Sistema de Gestión de Fondos
      </h2>
      <p className="text-xl mb-8">
        Gestiona tus suscripciones y consulta el historial de transacciones
      </p>
      
      <div className="grid grid-3">
        <div className="card">
          <h3 className="text-xl mb-4">Suscribirse</h3>
          <p className="mb-4">
            Suscríbete a un fondo de inversión y recibe notificaciones
          </p>
          <Link
            to="/subscribe"
            className="btn btn-primary"
          >
            Ir a Suscripción
          </Link>
        </div>

        <div className="card">
          <h3 className="text-xl mb-4">Cancelar</h3>
          <p className="mb-4">
            Cancela tu suscripción a un fondo de inversión
          </p>
          <Link
            to="/cancel"
            className="btn btn-danger"
          >
            Ir a Cancelación
          </Link>
        </div>

        <div className="card">
          <h3 className="text-xl mb-4">Historial</h3>
          <p className="mb-4">
            Consulta el historial completo de transacciones
          </p>
          <Link
            to="/history"
            className="btn btn-secondary"
          >
            Ver Historial
          </Link>
        </div>
      </div>
    </div>
  );
};

export default App;
