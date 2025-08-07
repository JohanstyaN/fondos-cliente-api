# Frontend - Client Funds Management

React frontend for the investment funds management system.

## Features

- Fund subscription and cancellation
- Transaction history
- Responsive design
- Error handling and notifications
- Modern UI with Tailwind CSS

## Tech Stack

- React 18 + TypeScript
- React Router DOM
- Axios for API calls
- Tailwind CSS

## Docker Build

```bash
docker build -t client-funds-frontend .
docker run -p 80:80 client-funds-frontend
```

## Development

```bash
npm install
npm start
```

## Instalación

1. Instalar dependencias:
```bash
npm install
```

2. Configurar la URL de la API:
   - Crear un archivo `.env` en la raíz del proyecto
   - Agregar: `REACT_APP_API_URL=http://localhost:8000`

## Ejecución

Para ejecutar en modo desarrollo:
```bash
npm start
```

La aplicación estará disponible en `http://localhost:3000`

## Estructura del proyecto

```
src/
├── components/          # Componentes de React
│   ├── SubscribeForm.tsx
│   ├── CancelForm.tsx
│   └── TransactionHistory.tsx
├── services/           # Servicios de API
│   └── api.ts
├── types/              # Tipos TypeScript
│   └── funds.ts
├── App.tsx             # Componente principal
└── index.tsx           # Punto de entrada
```

## Rutas disponibles

- `/` - Página de inicio
- `/subscribe` - Formulario de suscripción
- `/cancel` - Formulario de cancelación
- `/history` - Historial de transacciones

## API Endpoints

El frontend se conecta con los siguientes endpoints del backend:

- `GET /v1/funds/health` - Health check
- `POST /v1/funds/subscribe` - Suscribirse a un fondo
- `POST /v1/funds/cancel` - Cancelar suscripción
- `GET /v1/funds/history` - Obtener historial de transacciones
