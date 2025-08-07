# Client Funds Management System

Sistema de gestión de fondos de inversión para clientes con backend FastAPI y frontend React.

## 🏗️ Arquitectura

- **Backend**: FastAPI (Python) en puerto 8000
- **Frontend**: React (TypeScript) en puerto 80
- **Base de datos**: DynamoDB (4 tablas)
- **Notificaciones**: SNS (Email y SMS)
- **Infraestructura**: AWS ECS Fargate con ALB
- **Logs**: CloudWatch con retención de 14 días

## 📋 Prerrequisitos

- AWS CLI configurado
- Docker Desktop ejecutándose
- PowerShell 5.1+ (Windows)

## 🚀 Despliegue Rápido

```powershell
cd iac
.\deploy.ps1 deploy
```

## 🛠️ Comandos Disponibles

| Comando | Descripción |
|---------|-------------|
| `deploy` | Construir imágenes y desplegar/actualizar stack completo (por defecto) |
| `build` | Solo construir y subir imágenes Docker a ECR |
| `delete` | Eliminar el stack de CloudFormation |
| `status` | Mostrar estado del stack y URLs |
| `events` | Mostrar eventos recientes del stack |
| `help` | Mostrar ayuda |

### Ejemplos:
```powershell
# Despliegue completo
.\deploy.ps1 deploy

# Solo construcción de imágenes
.\deploy.ps1 build

# Ver estado y URLs
.\deploy.ps1 status

# Eliminar infraestructura
.\deploy.ps1 delete
```

## 📊 Datos de Prueba

Los datos de prueba se cargan automáticamente durante el despliegue.
No es necesario ejecutar scripts adicionales.

### Datos de Prueba Incluidos:

**Clientes:**
- user001: Juan Pérez (Balance: $10,000)
- user002: María García (Balance: $15,000)  
- user003: Carlos López (Balance: $5,000)

**Fondos:**
- FPV_BTG_PACTUAL_RECAUDADORA (Mínimo: $75,000)
- FPV_BTG_PACTUAL_ECOPETROL (Mínimo: $125,000)
- DEUDAPRIVADA (Mínimo: $50,000)
- FDO-ACCIONES (Mínimo: $250,000)
- FPV_BTG_PACTUAL_DINAMICA (Mínimo: $100,000)

## 🌐 Acceso a la Aplicación

Después del despliegue exitoso, el script mostrará:
- **Frontend URL**: `http://[ALB-DNS-NAME]`
- **Backend API**: `http://[ALB-DNS-NAME]/api/`
- **API Docs**: `http://[ALB-DNS-NAME]/docs`

## 📁 Estructura del Proyecto

```
📦 fondos-cliente-api
├── 📁 app/                     # Backend FastAPI
│   ├── 📁 config/             # Configuración
│   ├── 📁 models/             # Modelos de datos
│   ├── 📁 routers/            # Rutas de la API
│   ├── 📁 services/           # Lógica de negocio
│   └── 📁 utils/              # Utilidades
├── 📁 frontend/               # Frontend React
│   ├── 📁 src/
│   │   ├── 📁 components/     # Componentes React
│   │   ├── 📁 services/       # Cliente API
│   │   └── 📁 types/          # Tipos TypeScript
│   └── 📄 Dockerfile
├── 📁 iac/                    # Infraestructura
│   ├── 📄 template.yaml       # CloudFormation template
│   └── 📄 deploy.ps1          # Script despliegue completo
├── � scripts/                # Utilidades
│   ├── 📄 cleanup.ps1         # Limpiar recursos AWS
│   └── 📄 cleanup-new.ps1     # Limpiar recursos AWS (actualizado)
└── 📄 Dockerfile             # Backend Docker image
```

## 🗄️ Esquema de Base de Datos

### Clients
- **PK**: `user_id` (String)
- Campos: name, email, phone, balance

### Funds  
- **PK**: `id_fund` (String)
- Campos: name, minimum_amount, category

### TransactionHistory
- **PK**: `transaction_id` (String)
- Campos: user_id, id_fund, timestamp, transaction_type, amount, notification

### ClientFundRelation
- **PK**: `user_id#fund_id` (String)
- Campos: user_id, id_fund, subscribed_at

## 🔄 API Endpoints

### Transacciones
- `POST /api/v1/funds/transaction` - Crear transacción (suscribir/cancelar)
- `GET /api/v1/funds/history/{user_id}` - Historial de transacciones

### Salud
- `GET /health` - Health check del backend

## 📝 Logs y Monitoreo

- **CloudWatch Logs**: `/ecs/client-funds`
- **Streams**: `backend` y `frontend`
- **Retención**: 14 días
- **Container Insights**: Habilitado

## 🔧 Configuración

### Variables de Entorno (Backend)
- `SNS_EMAIL_TOPIC_ARN`: ARN del tópico SNS para emails
- `SNS_SMS_TOPIC_ARN`: ARN del tópico SNS para SMS  
- `AWS_DEFAULT_REGION`: Región AWS (us-east-1)

### Variables de Entorno (Frontend)
- `REACT_APP_API_URL`: URL del backend (configurada automáticamente)

## 🚨 Troubleshooting

### Problemas Comunes:

1. **Docker no está ejecutándose**
   ```bash
   # Verificar Docker
   docker info
   ```

2. **AWS CLI no configurado**
   ```bash
   aws configure
   aws sts get-caller-identity
   ```

3. **Stack en estado ROLLBACK**
   ```powershell
   .\deploy.ps1 delete
   .\deploy.ps1 deploy
   ```

4. **Health checks fallando**
   - Verificar logs en CloudWatch
   - Confirmar que las imágenes se construyeron correctamente

### Ver Logs:
```bash
# Ver eventos del stack
.\deploy.ps1 events

# Ver logs en CloudWatch (AWS Console)
# Grupo: /ecs/client-funds
# Streams: backend, frontend
```

## 🔐 Seguridad

- ALB Security Group: Solo puertos 80 HTTP
- ECS Security Group: Solo tráfico desde ALB
- IAM Roles: Principio de menor privilegio
- VPC: Subnets públicas con Internet Gateway

## 📈 Escalabilidad

- **ECS Service**: Auto Scaling configurado
- **DynamoDB**: Pay-per-request (escala automáticamente)
- **ALB**: Multi-AZ deployment
- **Fargate**: Sin gestión de servidores

## 🤝 Contribuir

1. Fork el proyecto
2. Crear rama de feature (`git checkout -b feature/AmazingFeature`)
3. Commit cambios (`git commit -m 'Add AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver archivo [LICENSE](LICENSE) para detalles.
