from pydantic import BaseModel, EmailStr, validator
from typing import Optional
from datetime import datetime

class UserBase(BaseModel):
    """Base model cho User"""
    username: str
    email: EmailStr
    full_name: str
    role: str = "teacher"

class UserCreate(UserBase):
    """Model để tạo User mới"""
    password: str
    
    @validator('password')
    def validate_password(cls, v):
        if len(v) < 6:
            raise ValueError('Password must be at least 6 characters long')
        return v
    
    @validator('username')
    def validate_username(cls, v):
        if len(v) < 3:
            raise ValueError('Username must be at least 3 characters long')
        if not v.isalnum():
            raise ValueError('Username must contain only alphanumeric characters')
        return v

class UserUpdate(BaseModel):
    """Model để cập nhật User"""
    email: Optional[EmailStr] = None
    full_name: Optional[str] = None
    role: Optional[str] = None
    is_active: Optional[bool] = None
    password: Optional[str] = None

class UserResponse(UserBase):
    """Model response cho User"""
    id: int
    is_active: bool
    created_at: datetime
    updated_at: Optional[datetime] = None

class TokenResponse(BaseModel):
    """Model response cho authentication token"""
    access_token: str
    refresh_token: str
    token_type: str
    expires_in: int

class UserLogin(BaseModel):
    """Model để đăng nhập"""
    username: str
    password: str
