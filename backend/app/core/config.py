from pydantic_settings import BaseSettings
from typing import List
import os



class Settings(BaseSettings):
    # Database
    
    database_url: str = "postgresql://username:password@localhost:5432/mobile_app_db"
    database_url_async: str = "postgresql+asyncpg://username:password@localhost:5432/mobile_app_db"
    
    # Security
    secret_key: str = "your-secret-key-here-change-in-production"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    
    # App
    debug: bool = True
    cors_origins: List[str] = ["http://localhost:3000", "http://localhost:8080"]
    
    # Server
    host: str = "0.0.0.0"
    port: int = 8000
    
    class Config:
        env_file = ".env"
        case_sensitive = False

settings = Settings()
