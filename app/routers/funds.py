from decimal import Decimal
import logging
from datetime import datetime
from typing import List
from fastapi import APIRouter, HTTPException
from app.models.fund import FundTransactionRequest, FundTransactionResponse, TransactionHistoryModel
from app.services.funds_service import create_transaction
import boto3
import os

logger = logging.getLogger("funds-router")
logging.basicConfig(level=logging.INFO)

router = APIRouter(prefix="/v1/funds", tags=["Funds"])

@router.get("/health")
def health_check():
    return {"status": "ok", "service": "funds-api"}

@router.post("/subscribe", response_model=FundTransactionResponse)
def subscribe(request: FundTransactionRequest):
    logger.info(f"Subscribe request: {request}")
    if request.transaction_type != "subscribe":
        raise HTTPException(status_code=400, detail="Invalid transaction type for this endpoint.")

    try:
        result = create_transaction(request.user_id, request.id_fund, request.transaction_type, request.notification_type)
        return FundTransactionResponse(**result)
    except ValueError as ve:
        logger.error(f"Subscribe error: {ve}")
        raise HTTPException(status_code=400, detail=str(ve))
    except RuntimeError as re:
        logger.error(f"Subscribe runtime error: {re}")
        raise HTTPException(status_code=500, detail=str(re))
    except Exception as e:
        logger.error(f"Subscribe unexpected error: {e}")
        raise HTTPException(status_code=500, detail=f"Unexpected error: {str(e)}")

@router.post("/cancel", response_model=FundTransactionResponse)
def cancel_subscription(request: FundTransactionRequest):
    logger.info(f"Cancel request: {request}")
    if request.transaction_type != "cancel":
        raise HTTPException(status_code=400, detail="Invalid transaction type for this endpoint.")
    
    try:
        result = create_transaction(request.user_id, request.id_fund, request.transaction_type)
        return FundTransactionResponse(**result)
    except ValueError as ve:
        logger.error(f"Cancel error: {ve}")
        raise HTTPException(status_code=400, detail=str(ve))
    except RuntimeError as re:
        logger.error(f"Cancel runtime error: {re}")
        raise HTTPException(status_code=500, detail=str(re))
    except Exception as e:
        logger.error(f"Cancel unexpected error: {e}")
        raise HTTPException(status_code=500, detail=f"Unexpected error: {str(e)}")

@router.get("/history", response_model=List[TransactionHistoryModel])
def transaction_history():
    logger.info("Fetching transaction history")
    try:
        dynamodb_endpoint = os.getenv('DYNAMODB_ENDPOINT_URL')
        if dynamodb_endpoint:
            dynamodb = boto3.resource('dynamodb', endpoint_url=dynamodb_endpoint)
        else:
            dynamodb = boto3.resource('dynamodb')
            
        table = dynamodb.Table('TransactionHistory')
        response = table.scan()
        items = response.get("Items", [])

        history = []
        for item in items:
            try:
                id_fund, timestamp_str = item["user_id#fund_id#timestamp"].split("#")[1:]
                timestamp = datetime.fromisoformat(timestamp_str)
                history.append(TransactionHistoryModel(
                    transaction_id=item["transaction_id"],
                    user_id=item["user_id"],
                    id_fund=id_fund,
                    timestamp=timestamp,
                    transaction_type=item["transaction_type"],
                    amount=Decimal(str(item["amount"])),
                    notification=item.get("notification", False)
                ))
            except Exception as e:
                logger.warning(f"Skipping invalid item: {e}")

        history.sort(key=lambda x: x.timestamp, reverse=True)
        return history
    except Exception as e:
        logger.error(f"Error fetching transaction history: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to fetch transaction history: {str(e)}")