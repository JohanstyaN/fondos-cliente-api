export interface FundTransactionRequest {
  user_id: string;
  id_fund: string;
  transaction_type: "subscribe" | "cancel";
  notification_type?: "email" | "sms";
}

export interface FundTransactionResponse {
  transaction_id: string;
  user_id: string;
  id_fund: string;
  transaction_type: "subscribe" | "cancel";
  new_balance: number;
  timestamp: string;
}

export interface TransactionHistoryModel {
  transaction_id: string;
  user_id: string;
  id_fund: string;
  timestamp: string;
  transaction_type: "subscribe" | "cancel";
  amount: number;
  notification: boolean;
}

export interface ClientModel {
  user_id: string;
  name: string;
  email: string;
  phone?: string;
  balance: number;
} 