# Client Funds Management System

<p align="center">
  <strong>Sistema completo de gestión de fondos de inversión con backend FastAPI, frontend React y despliegue automático en AWS</strong>
</p>

<p align="center">
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/python/python-original.svg" width="60" height="60" alt="Python"/>
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/fastapi/fastapi-original.svg" width="60" height="60" alt="FastAPI"/>
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/react/react-original.svg" width="60" height="60" alt="React"/>
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/typescript/typescript-original.svg" width="60" height="60" alt="TypeScript"/>
  <img src="https://www.svgrepo.com/show/331370/docker.svg" width="60" height="60" alt="Docker"/>
  <img src="https://images.icon-icons.com/2407/PNG/512/aws_icon_146074.png" width="60" alt="AWS"/>
  <img src="https://images.icon-icons.com/2699/PNG/512/nginx_logo_icon_169915.png" width="60" height="60" alt="Nginx"/>
</p>

## 🏗️ Arquitectura

- **Backend**: FastAPI (Python) ejecutándose en puerto 8000
- **Frontend**: React (TypeScript) servido por Nginx en puerto 80
- **Base de datos**: DynamoDB (4 tablas con escalado automático)
- **Notificaciones**: Amazon SNS (Email y SMS)
- **Infraestructura**: AWS ECS Fargate con Application Load Balancer
- **Contenedores**: Docker con imágenes almacenadas en ECR
- **Logs**: CloudWatch con retención de 14 días

## 🚀 Stack Técnico Completo

<div align="center">
  <strong>Backend & API</strong><br/>
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/python/python-original.svg" width="50" alt="Python"/>
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/fastapi/fastapi-original.svg" width="50" alt="FastAPI"/>
</div>

<br/>

<div align="center">
  <strong>Frontend</strong><br/>
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/react/react-original.svg" width="50" alt="React"/>
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/typescript/typescript-original.svg" width="50" alt="TypeScript"/>
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/html5/html5-original.svg" width="50" alt="HTML5"/>
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/css3/css3-original.svg" width="50" alt="CSS3"/>
  <img src="https://images.icon-icons.com/2699/PNG/512/nginx_logo_icon_169915.png" width="50" alt="Nginx"/>
</div>

<br/>

<div align="center">
  <strong>Cloud & Infraestructura</strong><br/>
  <img src="https://images.icon-icons.com/2407/PNG/512/aws_icon_146074.png" width="50" alt="AWS"/>
  <img src="https://user-images.githubusercontent.com/15157491/75435753-6929fc80-594b-11ea-9e19-f78223916862.png" width="40" alt="S3"/>
  <img src="https://www.svgrepo.com/download/353450/aws-dynamodb.svg" width="50" alt="DynamoDB"/>
  <img src="https://cdn.worldvectorlogo.com/logos/aws-sns.svg" width="50" alt="SNS"/>
</div>

<br/>

<div align="center">
  <strong>Contenedores & DevOps</strong><br/>
  <img src="https://www.svgrepo.com/show/331370/docker.svg" width="50" alt="Docker"/>
  <img src="https://symbols.getvecta.com/stencil_9/14_amazon-ecs.c923666086.png" width="50" alt="ECS"/>
  <img src="https://symbols.getvecta.com/stencil_9/12_amazon-ecr.df3492d909.png" width="50" alt="ECR"/>
  <img src="https://cdn.worldvectorlogo.com/logos/aws-cloudformation.svg" width="45" alt="CloudFormation"/>
</div>

<br/>

<div align="center">
  <strong>Herramientas</strong><br/>
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/git/git-original.svg" width="50" alt="Git"/>
  <img src="https://www.svgrepo.com/show/475654/github-color.svg" width="50" alt="GitHub"/>
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/vscode/vscode-original.svg" width="50" alt="VS Code"/>
  <img src="https://upload.wikimedia.org/wikipedia/commons/2/2f/PowerShell_5.0_icon.png" width="50" alt="PowerShell"/>
</div>

### 📋 Tecnologías Detalladas

**🐍 Backend:**
- Python 3.10+ con FastAPI
- Pydantic para validación de datos
- Boto3 para integración con AWS
- Uvicorn como servidor ASGI

**⚛️ Frontend:**
- React 18 con TypeScript
- Axios para comunicación con API
- CSS3 con diseño responsive
- Nginx para servir contenido estático

**☁️ AWS Services:**
- **ECS Fargate**: Contenedores serverless
- **DynamoDB**: Base de datos NoSQL
- **Application Load Balancer**: Balanceador de carga
- **ECR**: Registro de imágenes Docker
- **SNS**: Notificaciones push
- **CloudWatch**: Logs y monitoreo
- **CloudFormation**: Infraestructura como código

**🐳 DevOps:**
- Docker multi-stage builds
- PowerShell scripts para automatización
- CloudFormation para IaC
- GitHub para control de versiones

## 📋 Prerrequisitos

Antes de comenzar, asegúrate de tener:

### Software Requerido
- **AWS CLI** configurado con credenciales válidas
- **Docker Desktop** ejecutándose
- **PowerShell** 5.1+ (Windows)

### Configuración AWS
```powershell
# Verificar configuración AWS
aws configure list
aws sts get-caller-identity

# Si no está configurado:
aws configure
# Ingresa tu Access Key ID, Secret Access Key, región (us-east-1), y formato (json)
```

### Permisos AWS Requeridos
Tu usuario/rol AWS debe tener permisos para:
- CloudFormation (crear/actualizar/eliminar stacks)
- ECR (crear repositorios, push/pull imágenes)
- ECS (crear clusters, servicios, task definitions)
- EC2 (VPC, subnets, security groups, load balancers)
- DynamoDB (crear tablas, leer/escribir datos)
- SNS (crear topics)
- CloudWatch (crear log groups)
- IAM (crear roles y políticas)

## 🚀 Despliegue Rápido

### Configuración Inicial

1. **Clona el repositorio**:
   ```bash
   git clone https://github.com/TU_USUARIO/fondos-cliente-api.git
   cd fondos-cliente-api
   ```

2. **Configura tu Account ID** (IMPORTANTE):
   
   Edita los siguientes archivos y reemplaza `259711294275` con tu AWS Account ID:
   
   ```powershell
   # En iac/deploy.ps1 (línea 9)
   $global:ACCOUNT_ID = "TU_ACCOUNT_ID_AQUI"
   
   # En iac/build.ps1 (línea 13)  
   $global:ACCOUNT_ID = "TU_ACCOUNT_ID_AQUI"
   ```

3. **Despliega la aplicación**:
   ```powershell
   cd iac
   .\build.ps1 all      # Construir imágenes Docker
   .\deploy.ps1 all     # Desplegar infraestructura completa
   .\deploy.ps1 load-data  # Cargar datos de prueba (opcional)
   ```

### Ejemplo de Salida Exitosa
```
[SUCCESS] All images built and pushed!
[SUCCESS] Stack creation completed successfully
[SUCCESS] Application URL: http://client-funds-alb-XXXXXXXXX.us-east-1.elb.amazonaws.com
[SUCCESS] Frontend now has correct URL.
```

## 🛠️ Comandos Disponibles

### Scripts de Build
```powershell
# Construir todas las imágenes
.\build.ps1 all

# Construir solo backend
.\build.ps1 backend

# Construir solo frontend  
.\build.ps1 frontend

# Ver estado de las imágenes
.\build.ps1 status
```

### Scripts de Deploy
```powershell
# Despliegue completo (recomendado)
.\deploy.ps1 all

# Solo actualizar stack
.\deploy.ps1 stack

# Ver estado del stack
.\deploy.ps1 status

# Obtener URL de la aplicación
.\deploy.ps1 url

# Cargar datos de prueba
.\deploy.ps1 load-data

# Eliminar todo (con confirmación)
.\deploy.ps1 delete
```

## 📊 Datos de Prueba

El sistema incluye datos de prueba que se pueden cargar automáticamente:

### Clientes Disponibles
```json
{
  "user001": {
    "name": "Juan Pérez", 
    "email": "juan@example.com",
    "phone": "+1234567890",
    "balance": 500000
  },
  "user002": {
    "name": "María García",
    "email": "maria@example.com", 
    "phone": "+1234567891",
    "balance": 750000
  }
}
```

### Fondos Disponibles
- **FPV_BTG_PACTUAL_RECAUDADORA** (Mínimo: $75,000)
- **FPV_BTG_PACTUAL_ECOPETROL** (Mínimo: $125,000)
- **DEUDAPRIVADA** (Mínimo: $50,000)
- **FDO-ACCIONES** (Mínimo: $250,000)
- **FPV_BTG_PACTUAL_DINAMICA** (Mínimo: $100,000)

## 🌐 Usando la Aplicación

### Acceso Web
Después del despliegue, accede a la aplicación en la URL proporcionada:
- **Aplicación Web**: `http://[ALB-DNS-NAME]`
- **API Backend**: `http://[ALB-DNS-NAME]/v1/funds/`
- **Health Check**: `http://[ALB-DNS-NAME]/health`

### Funcionalidades Principales

1. **Suscribirse a Fondos**:
   - Navega a "Suscribirse"
   - Selecciona usuario y fondo
   - Elige tipo de notificación (Email/SMS)
   - Confirma la suscripción

2. **Cancelar Suscripciones**:
   - Ve a "Cancelar"
   - Selecciona usuario y fondo activo
   - Confirma la cancelación

3. **Ver Historial**:
   - Accede a "Historial"
   - Revisa todas las transacciones realizadas

## 📁 Estructura del Proyecto

```
📦 fondos-cliente-api/
├── 📁 app/                     # 🐍 Backend FastAPI
│   ├── 📁 config/             # Configuración
│   ├── 📁 models/             # Modelos Pydantic
│   ├── 📁 routers/            # Endpoints de la API
│   ├── 📁 services/           # Lógica de negocio
│   ├── 📁 utils/              # Utilidades y helpers
│   └── 📄 main.py             # Aplicación principal
├── 📁 frontend/               # ⚛️ Frontend React + TypeScript
│   ├── 📁 src/
│   │   ├── 📁 components/     # Componentes React
│   │   ├── 📁 services/       # Cliente API (Axios)
│   │   └── 📁 types/          # Definiciones TypeScript
│   ├── 📄 Dockerfile         # Multi-stage build con Nginx
│   └── 📄 nginx.conf         # Configuración Nginx
├── 📁 iac/                    # 🏗️ Infraestructura como Código  
│   ├── 📄 template.yaml       # CloudFormation template
│   ├── 📄 deploy.ps1          # Script principal de deploy
│   ├── 📄 build.ps1           # Script de build de imágenes
│   ├── 📄 data.json           # Datos de prueba
│   └── 📄 DEPLOYMENT-GUIDE.md # Guía detallada
├── 📁 tests/                  # 🧪 Tests automatizados
├── 📄 Dockerfile             # Imagen del backend
├── 📄 requirements.txt       # Dependencias Python
└── 📄 README.md              # Este archivo
```

## 🗄️ Esquema de Base de Datos (DynamoDB)

### Tabla: Clients
```
PK: user_id (String)
Attributes:
- name (String)
- email (String) 
- phone (String)
- balance (Number)
```

### Tabla: Funds
```
PK: id_fund (String)
Attributes:
- name (String)
- minimum_amount (Number)
- category (String)
```

### Tabla: TransactionHistory
```
PK: user_id#fund_id#timestamp (String)
Attributes:
- transaction_id (String)
- user_id (String)
- timestamp (String)
- transaction_type (String: subscribe|cancel)
- amount (Number)
- notification (Boolean)
```

### Tabla: ClientFundRelation
```
PK: user_id#fund_id (String)
Attributes:
- user_id (String)
- id_fund (String)
- subscribed_at (String)
```

## 🔄 API Endpoints

### Fondos
- `GET /v1/funds/health` - Health check
- `POST /v1/funds/subscribe` - Suscribirse a un fondo
- `POST /v1/funds/cancel` - Cancelar suscripción
- `GET /v1/funds/history` - Obtener historial de transacciones

### Ejemplo de Request
```javascript
// Suscribirse a un fondo
POST /v1/funds/subscribe
{
  "user_id": "user001",
  "id_fund": "FPV_BTG_PACTUAL_RECAUDADORA", 
  "transaction_type": "subscribe",
  "notification_type": "email"
}
```

### Ejemplo de Response
```javascript
{
  "transaction_id": "txn_abc123",
  "user_id": "user001",
  "id_fund": "FPV_BTG_PACTUAL_RECAUDADORA",
  "transaction_type": "subscribe",
  "amount": 75000,
  "timestamp": "2025-08-07T10:30:00Z",
  "message": "Suscripción exitosa",
  "notification_sent": true
}
```

## 📝 Logs y Monitoreo

### CloudWatch Logs
- **Grupo**: `/ecs/client-funds`
- **Streams**: `backend-{task-id}`, `frontend-{task-id}`
- **Retención**: 14 días

### Acceder a Logs
```powershell
# Ver logs en tiempo real (requiere AWS CLI)
aws logs tail /ecs/client-funds --follow

# Ver logs en AWS Console
https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:log-groups
```

## 🔧 Configuración Avanzada

### Variables de Entorno

**Backend (ECS Task)**:
- `SNS_EMAIL_TOPIC_ARN`: ARN del tópico SNS para emails
- `SNS_SMS_TOPIC_ARN`: ARN del tópico SNS para SMS
- `AWS_DEFAULT_REGION`: us-east-1

**Frontend (Runtime)**:
- `REACT_APP_API_URL`: URL del load balancer (configurada automáticamente)

### Personalización

Para adaptar el proyecto a tu entorno:

1. **Cambiar región AWS**: Edita `$global:REGION` en los scripts
2. **Modificar nombres**: Actualiza `$global:STACK_NAME` y nombres de repositorios
3. **Ajustar recursos**: Modifica `template.yaml` para CPU, memoria, etc.

## 🚨 Troubleshooting

### Problemas Comunes

#### 1. Docker no disponible
```powershell
# Verificar Docker
docker info

# Si falla, iniciar Docker Desktop
```

#### 2. Credenciales AWS incorrectas
```powershell
# Verificar identidad
aws sts get-caller-identity

# Reconfigurar si es necesario  
aws configure
```

#### 3. Stack en estado de error
```powershell
# Ver eventos detallados
aws cloudformation describe-stack-events --stack-name client-funds-stack

# Eliminar y recrear
.\deploy.ps1 delete
.\deploy.ps1 all
```

#### 4. Frontend no carga
- Verificar que la URL sea accesible: `http://[ALB-DNS]/health`
- Revisar logs del frontend en CloudWatch
- Confirmar que el ALB Target Group esté healthy

#### 5. API devuelve 405 Method Not Allowed
- Verificar que las rutas del ALB estén configuradas correctamente
- Confirmar que el backend esté respondiendo en `/health`

### Logs Útiles
```powershell
# Estado del stack
.\deploy.ps1 status

# Eventos recientes del stack
aws cloudformation describe-stack-events --stack-name client-funds-stack --max-items 10

# Logs de ECS (últimas 2 horas)
aws logs filter-log-events --log-group-name /ecs/client-funds --start-time $(Get-Date).AddHours(-2).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
```

## 🔐 Seguridad

### Configuración de Red
- **VPC**: Red privada con 2 subnets públicas en AZs diferentes
- **ALB Security Group**: Solo puerto 80 (HTTP) desde internet
- **ECS Security Group**: Solo tráfico desde ALB en puertos 80 y 8000
- **Internet Gateway**: Para acceso saliente de contenedores

### IAM y Permisos
- **ECS Task Execution Role**: Permisos mínimos para ECR y CloudWatch
- **ECS Task Role**: Acceso a DynamoDB y SNS
- **Principio de menor privilegio**: Cada servicio solo tiene los permisos necesarios

## 📈 Escalabilidad y Performance

### Auto Scaling Configurado
- **ECS Service**: Escala automáticamente basado en CPU/memoria
- **DynamoDB**: Modo on-demand (escala automáticamente)
- **ALB**: Multi-AZ con health checks

### Optimizaciones Incluidas
- **Docker Multi-stage builds**: Imágenes optimizadas
- **Nginx**: Compresión gzip y cache de assets estáticos
- **CloudWatch**: Retention de logs optimizada
- **ECS Fargate**: Sin gestión de servidores

## 📊 Estadísticas del Proyecto

<p align="center">
  <img src="https://img.shields.io/github/languages/top/JohanstyaN/fondos-cliente-api?style=for-the-badge&logo=python&logoColor=white" alt="Top Language"/>
  <img src="https://img.shields.io/github/languages/count/JohanstyaN/fondos-cliente-api?style=for-the-badge" alt="Language Count"/>
  <img src="https://img.shields.io/github/repo-size/JohanstyaN/fondos-cliente-api?style=for-the-badge" alt="Repo Size"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/AWS-ECS_Fargate-orange?style=for-the-badge&logo=amazon-aws&logoColor=white" alt="AWS ECS"/>
  <img src="https://img.shields.io/badge/Database-DynamoDB-blue?style=for-the-badge&logo=amazon-dynamodb&logoColor=white" alt="DynamoDB"/>
  <img src="https://img.shields.io/badge/Infrastructure-CloudFormation-yellow?style=for-the-badge&logo=amazon-aws&logoColor=white" alt="CloudFormation"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Backend-FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white" alt="FastAPI"/>
  <img src="https://img.shields.io/badge/Frontend-React-61DAFB?style=for-the-badge&logo=react&logoColor=black" alt="React"/>
  <img src="https://img.shields.io/badge/Container-Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker"/>
</p>

### 🏆 Características del Proyecto

- ✅ **Arquitectura Serverless**: ECS Fargate sin gestión de servidores
- ✅ **Escalabilidad Automática**: DynamoDB on-demand y ECS auto-scaling  
- ✅ **Deploy Automatizado**: Un solo comando para despliegue completo
- ✅ **Multi-container**: Frontend y Backend en contenedores separados
- ✅ **Infraestructura como Código**: CloudFormation template completo
- ✅ **Monitoreo Integrado**: CloudWatch logs y métricas
- ✅ **Seguridad por Capas**: VPC, Security Groups, IAM roles
- ✅ **Notificaciones**: SNS para Email y SMS
- ✅ **API RESTful**: Documentación automática con FastAPI
- ✅ **Frontend Responsivo**: React con TypeScript

