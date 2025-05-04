#!/bin/bash
set -euo pipefail

STACK_NAME="funds-client-stack"
TEMPLATE_FILE="iac/template.yaml"
IMAGE_URI="259711294275.dkr.ecr.us-east-1.amazonaws.com/fondos-cliente-api:latest"
REGION="us-east-1"

echo "Desplegando stack..."
aws cloudformation deploy \
  --template-file "$TEMPLATE_FILE" \
  --stack-name "$STACK_NAME" \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    ContainerImage="$IMAGE_URI" \
    ALBPort=8000

echo "Esperando a que el stack esté en estado 'CREATE_COMPLETE'..."
FUNDS_TABLE=$(aws dynamodb list-tables \
  --region "$REGION" \
  --query "TableNames[?contains(@, 'Funds')]" \
  --output text)
CLIENT_TABLE=$(aws dynamodb list-tables \
  --region "$REGION" \
  --query "TableNames[?contains(@, 'Client') && !contains(@, 'Relation')]" \
  --output text)
SNS_EMAIL_TOPIC=$(aws sns list-topics \
  --region "$REGION" \
  --query "Topics[?contains(TopicArn, 'funds-client-notification-topic')].TopicArn" \
  --output text)
SNS_SMS_TOPIC=$(aws sns list-topics \
  --region "$REGION" \
  --query "Topics[?contains(TopicArn, 'funds-client-sms-topic')].TopicArn" \
  --output text)

# Funds
if aws dynamodb get-item --region "$REGION" --table-name "$FUNDS_TABLE" \
     --key '{"id_fund": {"S": "DEUDAPRIVADA"}}' --query 'Item' --output text >/dev/null; then
  echo "  Funds ya poblada, nada que hacer."
else
  echo "  Insertando datos en $FUNDS_TABLE..."
  aws dynamodb batch-write-item --region "$REGION" --request-items file://iac/data/funds.json
fi

# Clients
if aws dynamodb get-item --region "$REGION" --table-name "$CLIENT_TABLE" \
     --key '{"user_id": {"S": "user-001"}}' --query 'Item' --output text >/dev/null; then
  echo "  Clients ya poblada, nada que hacer."
else
  echo "  Insertando datos en $CLIENT_TABLE..."
  aws dynamodb batch-write-item --region "$REGION" --request-items file://iac/data/clients.json
fi

# Email
if aws sns list-subscriptions-by-topic \
     --topic-arn "$SNS_EMAIL_TOPIC" --region "$REGION" \
     --query "Subscriptions[?Endpoint=='sebastyancanon@gmail.com']" --output text | grep -q .; then
  echo "  Suscripción de email ya existe."
else
  echo "  Creando suscripción de email..."
  aws sns subscribe --region "$REGION" \
    --topic-arn "$SNS_EMAIL_TOPIC" \
    --protocol email \
    --notification-endpoint sebastyancanon@gmail.com
fi

# SMS
if aws sns list-subscriptions-by-topic \
     --topic-arn "$SNS_SMS_TOPIC" --region "$REGION" \
     --query "Subscriptions[?Endpoint=='+573123438775']" --output text | grep -q .; then
  echo "  Suscripción SMS ya existe."
else
  echo "  Creando suscripción de SMS..."
  aws sns subscribe --region "$REGION" \
    --topic-arn "$SNS_SMS_TOPIC" \
    --protocol sms \
    --notification-endpoint +573123438775
fi

