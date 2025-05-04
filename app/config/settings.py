from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    sns_topic_arn: str

    model_config = {
        "env_file": ".env"
    }

settings = Settings()
