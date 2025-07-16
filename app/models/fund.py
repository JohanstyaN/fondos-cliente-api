from decimal import Decimal
from pydantic import BaseModel, EmailStr, Field
from typing import Literal, Optional
from datetime import datetime

class FundTransactionRequest(BaseModel):
    user_id: str = Field(..., example="user123")
    id_fund: str = Field(..., example="fondo456")
    transaction_type: Literal["subscribe", "cancel"]
    notification_type: Optional[Literal["email", "sms"]] = Field(
        default=None, example="email"
    )

class FundTransactionResponse(BaseModel):
    transaction_id: str
    user_id: str
    id_fund: str
    transaction_type: Literal["subscribe", "cancel"]
    new_balance: float
    timestamp: datetime

class TransactionHistoryModel(BaseModel):
    transaction_id: str
    user_id: str
    id_fund: str
    timestamp: datetime
    transaction_type: Literal["subscribe", "cancel"]
    amount: Decimal
    notification: bool


class ClientModel(BaseModel):
    user_id: str 
    name: str 
    email: EmailStr 
    phone: Optional[str] 
    balance: float 


