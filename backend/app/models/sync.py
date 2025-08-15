from pydantic import BaseModel
from typing import List, Dict, Any, Optional
from datetime import datetime
from enum import Enum

class SyncStatus(str, Enum):
    SUCCESS = "success"
    FAILED = "failed"
    PARTIAL = "partial"
    PENDING = "pending"

class AttendanceRecord(BaseModel):
    student_id: int
    date: str
    check_in_time: Optional[str] = None
    check_out_time: Optional[str] = None
    status: str
    location: Optional[str] = None
    device_id: Optional[str] = None

class SyncRequest(BaseModel):
    device_id: str
    timestamp: datetime
    attendance_records: List[AttendanceRecord]
    device_info: Optional[Dict[str, Any]] = None

class SyncResponse(BaseModel):
    status: SyncStatus
    message: str
    records_processed: int
    timestamp: datetime
    errors: Optional[List[str]] = None

class DeviceSyncStatus(BaseModel):
    device_id: str
    last_sync: datetime
    status: SyncStatus
    pending_changes: int
    last_error: Optional[str] = None
