# 💰 Fondos Cliente API

Una API RESTful desarrollada con **FastAPI** para gestionar suscripciones y cancelaciones de fondos de clientes, respaldada por AWS DynamoDB y notificaciones vía SNS.

Incluye:
- Contenedores Docker (FastAPI)  
- Infraestructura como código en Terraform (carpeta `iac`)  
- Suite de tests automatizados con **pytest**  
- Endpoints documentados con OpenAPI/Swagger UI  

---

## 🚀 Características

### Health Check
- **GET** `/v1/funds/health`  
  Comprueba que la API está viva.

### Suscripción y Cancelación
- **POST** `/v1/funds/subscribe`  
  Crea una suscripción de un cliente a un fondo.  
  - Request body:  
    ```json
    {
      "user_id": "user123",
      "id_fund": "fondo456",
      "transaction_type": "subscribe",
      "notification_type": "email"
    }
    ```
- **POST** `/v1/funds/cancel`  
  Cancela la suscripción de un cliente a un fondo.  
  - Request body igual al de suscripción, con `"transaction_type": "cancel"`.

### Historial de Transacciones
- **GET** `/v1/funds/history`  
  Recupera todas las transacciones (suscripciones y cancelaciones), ordenadas por fecha.

---

## 📦 Requisitos

- Docker (para containerización)  
- Python 3.10+ y `pip` (para ejecución local)  
- AWS CLI/configuraciones o credenciales con permisos sobre DynamoDB y SNS  
- Terraform (opcional, si vas a desplegar la infraestructura desde `iac/`)  

---

## 🔧 Variables de entorno

Crea un fichero \`.env\` en la raíz del proyecto con al menos:

~~~dotenv
# SNS (notificaciones)
SNS_EMAIL_TOPIC_ARN=arn:aws:sns:us-east-1:123456789012:funds-client-email-topic
SNS_SMS_TOPIC_ARN=arn:aws:sns:us-east-1:123456789012:funds-client-sms-topic

# AWS (si no usas IAM role)
AWS_ACCESS_KEY_ID=TU_ACCESS_KEY
AWS_SECRET_ACCESS_KEY=TU_SECRET_KEY
AWS_DEFAULT_REGION=us-east-1
~~~

---

## 🏗️ Instalación y ejecución

### Con Docker

~~~bash
# 1. Clona el repositorio
git clone https://github.com/JohanstyaN/fondos-cliente-api.git
cd fondos-cliente-api

# 2. Copia el .env y ajusta variables
cp .env.sample .env   # si hubiera un .env.sample

# 3. Construye la imagen
docker build -t fondos-cliente-api .

# 4. Ejecuta el contenedor
docker run -d --name fondos-api \
  --env-file .env \
  -p 8000:8000 \
  fondos-cliente-api
~~~

### Local (sin Docker)

~~~bash
git clone https://github.com/JohanstyaN/fondos-cliente-api.git
cd fondos-cliente-api
python3 -m venv .venv && source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
~~~

---

## 📡 Documentación interactiva

~~~text
Swagger UI → http://localhost:8000/docs  
ReDoc      → http://localhost:8000/redoc
~~~

---

## 🔍 Probar con curl

~~~bash
# Health check
curl http://localhost:8000/v1/funds/health

# Suscribirse a un fondo
curl -X POST http://localhost:8000/v1/funds/subscribe \
     -H "Content-Type: application/json" \
     -d '{"user_id":"user123","id_fund":"fondo456","transaction_type":"subscribe","notification_type":"email"}'

# Cancelar suscripción
curl -X POST http://localhost:8000/v1/fonds/cancel \
     -H "Content-Type: application/json" \
     -d '{"user_id":"user123","id_fund":"fondo456","transaction_type":"cancel"}'

# Historial de transacciones
curl http://localhost:8000/v1/funds/history
~~~

---

## 🧪 Tests automatizados

~~~bash
# Instala pytest si no está
pip install pytest

# Ejecuta todos los tests
pytest -q
~~~

---

## 📁 Estructura del proyecto

~~~text
fondos-cliente-api/
├── app/
│   ├── main.py                     # Punto de entrada FastAPI
│   ├── routers/
│   │   └── funds.py                # Definición de endpoints
│   ├── models/
│   │   └── fund.py                 # Pydantic models
│   ├── services/
│   │   ├── funds_service.py        # Lógica de negocio
│   │   └── client_service.py       # CRUD de clientes
│   └── utils/
│       ├── relations.py            # Relación cliente–fondo en DynamoDB
│       └── notifier.py             # Envío de notificaciones SNS
├── iac/                            # Terraform para DynamoDB, SNS, IAM…
├── tests/                          # Tests con pytest para routers y servicios
├── .env                            # Variables de entorno (no versionar)
├── .gitignore
├── Dockerfile
├── requirements.txt
└── README.md
~~~

---

## ⚠️ Notas importantes

- Asegúrate de crear las tablas de DynamoDB:
  - `Funds` (con `id_fund`, `minimum_amount`)
  - `Client` (con `user_id`, `balance`, `email`, …)
  - `ClientFundRelation` (con `user_id`, `id_fund`, `subscribed_at`)
  - `TransactionHistory` (con `id_transaction`, `user_id#fund_id#timestamp`, …)
- Configura tus SNS topics y coloca sus ARNs en el \`.env\`.
- En producción, usa IAM Roles y KMS para cifrar variables sensibles.

---

## 👤 Autor

Desarrollado por **Johan Sebastián Cañon**  
GitHub: [@JohanstyaN](https://github.com/JohanstyaN)  
LinkedIn: [linkedin.com/in/johan-sebastian-cañon-932b0b240](https://www.linkedin.com/in/johan-sebastian-cañon-932b0b240/)
