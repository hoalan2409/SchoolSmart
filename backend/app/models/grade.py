from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime

class GradeBase(BaseModel):
    name: str = Field(..., description="Grade name (e.g., Grade 10, Grade 11)")
    description: Optional[str] = None
    is_active: bool = Field(True, description="Whether the grade is active")

class GradeCreate(GradeBase):
    pass

class GradeUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    is_active: Optional[bool] = None

class GradeResponse(GradeBase):
    id: int
    created_at: datetime
    updated_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }

class GradeListResponse(BaseModel):
    grades: List[GradeResponse]
    total: int
    skip: int
    limit: int
