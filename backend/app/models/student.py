from pydantic import BaseModel, Field, EmailStr
from typing import Optional
from datetime import date, datetime

class StudentBase(BaseModel):
    full_name: str = Field(..., description="Student's full name")
    email: Optional[EmailStr] = Field(None, description="Student's email address")  # Đổi thành optional
    grade: str = Field(..., description="Student's grade level")
    # section: str = Field(..., description="Student's section") # Removed section field
    date_of_birth: Optional[date] = Field(None, description="Student's date of birth")
    phone: Optional[str] = Field(None, description="Student's phone number")
    address: Optional[str] = Field(None, description="Student's address")
    parent_name: Optional[str] = Field(None, description="Parent's name")
    parent_phone: Optional[str] = Field(None, description="Parent's phone number")
    parent_email: Optional[str] = Field(None, description="Parent's email address")
    photo_path: Optional[str] = Field(None, description="Path to student's photo for ML")

class StudentCreate(StudentBase):
    pass

class StudentUpdate(BaseModel):
    full_name: Optional[str] = None
    email: Optional[EmailStr] = None
    grade: Optional[str] = None
    # section: Optional[str] = None # Removed section field
    date_of_birth: Optional[date] = None
    phone: Optional[str] = None
    address: Optional[str] = None
    parent_name: Optional[str] = None
    parent_phone: Optional[str] = None
    parent_email: Optional[str] = None
    photo_path: Optional[str] = None

class StudentResponse(StudentBase):
    id: int
    student_code: str  # Thêm student_code vào response
    created_at: datetime
    updated_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True
        json_encoders = {
            datetime: lambda v: v.isoformat(),
            date: lambda v: v.isoformat()
        }
