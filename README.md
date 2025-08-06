# 💰 Fondos Cliente API

Una API RESTful desarrollada con **FastAPI** para gestionar suscripciones y cancelaciones de fondos de clientes, respaldada por AWS DynamoDB y notificaciones vía SNS.

Incluye:
- Contenedores Docker (FastAPI)  
- Infraestructura como código (IaC) en AWS CloudFormation (carpeta `iac/`)  
- Suite de tests automatizados con **pytest**  
- Endpoints documentados con OpenAPI/Swagger UI  
- Despliegue serverless en AWS ECS Fargate  
- Notificaciones por **email/SMS** vía AWS SNS  
- Monitorización con **CloudWatch Logs**  

---

## 🚀 Características

### Health Check
- **GET** `/v1/funds/health`  
  Verifica que la API está viva.

### Suscripción y Cancelación

- **POST** `/v1/funds/subscribe`  
  Crea una suscripción de un cliente a un fondo.

- **POST** `/v1/funds/cancel`  
  Cancela la suscripción de un cliente a un fondo.

~~~json
{
  "user_id": "user123",
  "id_fund": "fondo456",
  "transaction_type": "subscribe",
  "notification_type": "email"
}
~~~

### Historial de Transacciones

- **GET** `/v1/funds/history`  
  Devuelve todas las transacciones del cliente, ordenadas por fecha.

---

## 🧱 Arquitectura y Componentes

- **Backend:** Python + FastAPI + Uvicorn  
- **Contenedor:** Docker  
- **Infraestructura:** AWS CloudFormation (IaC)  
- **Ejecución:** ECS Fargate + API Gateway + Load Balancer  
- **Base de datos:** DynamoDB (NoSQL)  
- **Mensajería:** AWS SNS (notificaciones por Email/SMS)  
- **CI/CD:** Script automatizado con `deploy-stack.sh`  
- **Monitorización:** AWS CloudWatch  
- **Seguridad:** IAM Roles con mínimos privilegios + HTTPS  

---

## 🧩 Modelo de datos (DynamoDB)

| Tabla | Claves | Descripción |
|-------|--------|-------------|
| **Clients** | `user_id` (PK) | name, email, phone, balance, created_at |
| **Funds** | `id_fund` (PK) | name, category, minimum_amount |
| **ClientFundRelation** | `user_id` (PK), `id_fund` (SK) | Relación cliente–fondo |
| **TransactionHistory** | `id_transaction` (PK), `user_id#fund_id#timestamp` (SK) | Registro de operaciones |

---

## 📦 Requisitos

- Docker  
- Python 3.10+  
- AWS CLI configurado (`us-east-1`)  
- Git Bash o WSL (para ejecutar `deploy-stack.sh`)  
- Permisos en AWS:  
  `CloudFormation`, `ECR`, `ECS`, `DynamoDB`, `SNS`, `IAM`, `CloudWatch`, `ELBv2`, `ApiGatewayV2`

---

## 🛠️ Variables de entorno

~~~dotenv
SNS_EMAIL_TOPIC_ARN=arn:aws:sns:us-east-1:<ACCOUNT_ID>:funds-client-email-topic
SNS_SMS_TOPIC_ARN=arn:aws:sns:us-east-1:<ACCOUNT_ID>:funds-client-sms-topic

AWS_ACCESS_KEY_ID=TU_ACCESS_KEY
AWS_SECRET_ACCESS_KEY=TU_SECRET_KEY
AWS_DEFAULT_REGION=us-east-1
~~~

---

## 🐳 Uso con Docker

~~~bash
# 1. Clona el repositorio
git clone https://github.com/JohanstyaN/fondos-cliente-api.git
cd fondos-cliente-api

# 2. Construye la imagen Docker
docker build -t fondos-cliente-api .

# 3. Ejecuta el contenedor
docker run -d --name fondos-api \\
  --env-file .env \\
  -p 8000:8000 \\
  fondos-cliente-api
~~~

---

## 🔧 Deploy en AWS (CloudFormation)

### 1️⃣ Subir imagen a ECR

~~~bash
docker build -t fondos-cliente-api .

docker tag fondos-cliente-api:latest 259711294275.dkr.ecr.us-east-1.amazonaws.com/fondos-cliente-api:latest

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 259711294275.dkr.ecr.us-east-1.amazonaws.com

docker push 259711294275.dkr.ecr.us-east-1.amazonaws.com/fondos-cliente-api:latest
~~~

> 📌 Asegúrate de colocar la misma URL de imagen en `iac/parameters.json`.

---

### 2️⃣ Ejecutar el despliegue (CloudFormation)

> ⚠️ **IMPORTANTE**: Usa Git Bash (Windows) o cualquier consola Bash compatible.

~~~bash
bash iac/deploy-stack.sh
~~~

Este script:
- Despliega o actualiza el stack de AWS.
- Inserta datos iniciales en DynamoDB si están vacíos.
- Crea suscripciones SNS (evitando duplicados).

---

### 3️⃣ Validación

- Revisa el endpoint generado:  
  `https://<api-id>.execute-api.us-east-1.amazonaws.com/v1`

- Prueba el Swagger UI:  
  `https://<api-id>.execute-api.us-east-1.amazonaws.com/v1/docs`

---

## 📡 Pruebas con curl

~~~bash
# Health check
curl http://localhost:8000/v1/funds/health

# Suscripción
curl -X POST http://localhost:8000/v1/funds/subscribe \\
  -H "Content-Type: application/json" \\
  -d '{"user_id":"user123","id_fund":"fondo456","transaction_type":"subscribe","notification_type":"email"}'

# Cancelar suscripción
curl -X POST http://localhost:8000/v1/funds/cancel \\
  -H "Content-Type: application/json" \\
  -d '{"user_id":"user123","id_fund":"fondo456","transaction_type":"cancel"}'

# Historial
curl http://localhost:8000/v1/funds/history
~~~

---

## 🧪 Tests automatizados

~~~bash
pip install -r requirements.txt
pytest -q
~~~

---

## 📁 Estructura del proyecto

~~~text
fondos-cliente-api/
├── app/
│   ├── main.py
│   ├── routers/
│   ├── models/
│   ├── services/
│   └── utils/
├── iac/
│   ├── deploy-stack.sh
│   └── parameters.json
├── tests/
├── .env
├── Dockerfile
└── README.md
~~~

---

## 👤 Autor

Desarrollado por **Johan Sebastián Cañon**  
GitHub: [@JohanstyaN](https://github.com/JohanstyaN)  
LinkedIn: [linkedin.com/in/johan-sebastian-cañon-932b0b240](https://www.linkedin.com/in/johan-sebastian-cañon-932b0b240/)
