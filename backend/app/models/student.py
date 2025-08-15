from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import date
from enum import Enum

class Gender(str, Enum):
    MALE = "male"
    FEMALE = "female"
    OTHER = "other"

class StudentBase(BaseModel):
    student_code: str
    full_name: str
    date_of_birth: date
    gender: Gender
    class_name: str
    email: Optional[EmailStr] = None
    phone: Optional[str] = None
    address: Optional[str] = None

class StudentCreate(StudentBase):
    pass

class StudentUpdate(BaseModel):
    student_code: Optional[str] = None
    full_name: Optional[str] = None
    date_of_birth: Optional[date] = None
    gender: Optional[Gender] = None
    class_name: Optional[str] = None
    email: Optional[EmailStr] = None
    phone: Optional[str] = None
    address: Optional[str] = None

class StudentResponse(StudentBase):
    id: int
    
    class Config:
        from_attributes = True
