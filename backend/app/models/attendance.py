from pydantic import BaseModel
from typing import Optional
from datetime import datetime, date
from enum import Enum

class AttendanceType(str, Enum):
    CHECK_IN = "check_in"
    CHECK_OUT = "check_out"

class AttendanceStatus(str, Enum):
    PRESENT = "present"
    ABSENT = "absent"
    LATE = "late"
    EXCUSED = "excused"

class AttendanceBase(BaseModel):
    student_id: int
    date: date
    check_in_time: Optional[datetime] = None
    check_out_time: Optional[datetime] = None
    status: AttendanceStatus
    location: Optional[str] = None
    device_id: Optional[str] = None
    notes: Optional[str] = None

class AttendanceCreate(AttendanceBase):
    pass

class AttendanceUpdate(BaseModel):
    check_in_time: Optional[datetime] = None
    check_out_time: Optional[datetime] = None
    status: Optional[AttendanceStatus] = None
    location: Optional[str] = None
    notes: Optional[str] = None

class AttendanceResponse(AttendanceBase):
    id: int
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

class AttendanceStats(BaseModel):
    total_students: int
    present_today: int
    absent_today: int
    late_today: int
    attendance_rate: float
