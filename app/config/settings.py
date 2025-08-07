import os
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    sns_topic_arn: str = os.getenv("SNS_SMS_TOPIC_ARN", "")
    sns_email_topic_arn: str = os.getenv("SNS_EMAIL_TOPIC_ARN", "")
    aws_region: str = os.getenv("AWS_DEFAULT_REGION", "us-east-1")

settings = Settings()
