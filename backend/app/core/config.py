from pydantic_settings import BaseSettings
from typing import List, Optional
import os

class Settings(BaseSettings):
    """Cấu hình ứng dụng SchoolSmart"""
    
    # App settings
    APP_NAME: str = "SchoolSmart Backend"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False
    
    # Server settings
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    
    # Database
    DATABASE_URL: str = "postgresql://postgres:123456@localhost/schoolsmart"
    DATABASE_POOL_SIZE: int = 20
    DATABASE_MAX_OVERFLOW: int = 30
    
    # Security
    SECRET_KEY: str = "your-secret-key-change-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    
    # CORS
    ALLOWED_HOSTS: List[str] = ["*"]
    
    # AI Models
    FACE_RECOGNITION_MODEL_PATH: str = "models/arcface_model.onnx"
    FACE_DETECTION_MODEL_PATH: str = "models/blazeface_model.onnx"
    EMBEDDING_DIMENSION: int = 512
    FACE_DETECTION_CONFIDENCE: float = 0.8
    FACE_RECOGNITION_THRESHOLD: float = 0.6
    
    # File storage
    UPLOAD_DIR: str = "uploads"
    MAX_FILE_SIZE: int = 10 * 1024 * 1024  # 10MB
    ALLOWED_IMAGE_TYPES: List[str] = ["image/jpeg", "image/png", "image/webp"]
    
    # Sync settings
    SYNC_INTERVAL_SECONDS: int = 300  # 5 phút
    BATCH_SIZE: int = 100
    
    # Logging
    LOG_LEVEL: str = "INFO"
    LOG_FILE: str = "logs/schoolsmart.log"
    
    # Redis (cho cache và queue)
    REDIS_URL: str = "redis://localhost:6379"
    
    # Email (cho thông báo)
    SMTP_HOST: str = "smtp.gmail.com"
    SMTP_PORT: int = 587
    SMTP_USER: str = ""
    SMTP_PASSWORD: str = ""
    
    class Config:
        env_file = ".env"
        case_sensitive = True

# Tạo instance settings
settings = Settings()

# Tạo thư mục cần thiết
os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
os.makedirs("logs", exist_ok=True)
os.makedirs("models", exist_ok=True)
