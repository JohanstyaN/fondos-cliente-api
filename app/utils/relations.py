from datetime import datetime, timezone
import boto3
import os
import logging

logger = logging.getLogger("relations")
logger.setLevel(logging.INFO)

dynamodb_endpoint = os.getenv('DYNAMODB_ENDPOINT_URL')
if dynamodb_endpoint:
    dynamodb = boto3.resource('dynamodb', endpoint_url=dynamodb_endpoint)
else:
    dynamodb = boto3.resource('dynamodb')

relation_table = dynamodb.Table('ClientFundRelation')

def is_subscribed(user_id: str, fund_id: str) -> bool:
    try:
        key = f"{user_id}#{fund_id}"
        logger.info(f"Checking subscription for key: {key}")
        response = relation_table.get_item(
            Key={'user_id#fund_id': key}
        )
        is_sub = 'Item' in response
        logger.info(f"Subscription check result: {is_sub}")
        return is_sub
    except Exception as e:
        logger.error(f"Error checking subscription: {e}")
        return False

def create_subscription_record(user_id: str, fund_id: str):
    try:
        key = f"{user_id}#{fund_id}"
        item_data = {
            'user_id#fund_id': key,
            'user_id': user_id,
            'id_fund': fund_id,
            'subscribed_at': datetime.now(timezone.utc).isoformat()
        }
        logger.info(f"Creating subscription record: {item_data}")
        
        relation_table.put_item(Item=item_data)
        logger.info(f"✅ Subscription record created successfully for {key}")
        
        # Verify insertion
        verify_response = relation_table.get_item(Key={'user_id#fund_id': key})
        if 'Item' in verify_response:
            logger.info(f"✅ Verification: Record exists in table")
        else:
            logger.error(f"❌ Verification failed: Record not found after insertion")
            
    except Exception as e:
        logger.error(f"❌ Error creating subscription record: {e}")
        raise

def delete_subscription_record(user_id: str, fund_id: str):
    try:
        key = f"{user_id}#{fund_id}"
        logger.info(f"Deleting subscription record: {key}")
        
        relation_table.delete_item(
            Key={'user_id#fund_id': key}
        )
        logger.info(f"✅ Subscription record deleted successfully for {key}")
        
    except Exception as e:
        logger.error(f"❌ Error deleting subscription record: {e}")
        raise
