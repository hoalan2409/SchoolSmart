from pydantic import BaseModel, validator
from typing import List, Optional
from datetime import datetime

class FaceRegistrationRequest(BaseModel):
    """Request model cho đăng ký khuôn mặt"""
    student_id: int
    images_count: int
    
    @validator('images_count')
    def validate_images_count(cls, v):
        if v < 3 or v > 5:
            raise ValueError('Images count must be between 3 and 5')
        return v

class FaceRegistrationResponse(BaseModel):
    """Response model cho đăng ký khuôn mặt"""
    student_id: int
    student_name: str
    embeddings_count: int
    confidence_scores: List[float]
    message: str

class FaceRecognitionRequest(BaseModel):
    """Request model cho nhận diện khuôn mặt"""
    location: Optional[str] = None
    device_id: Optional[str] = None

class FaceRecognitionResponse(BaseModel):
    """Response model cho nhận diện khuôn mặt"""
    student_id: Optional[int] = None
    student_name: Optional[str] = None
    confidence_score: float
    recognition_time: datetime
    location: Optional[str] = None
    device_id: Optional[str] = None
    status: str  # "recognized" hoặc "unknown"

class FaceEmbeddingResponse(BaseModel):
    """Response model cho face embedding"""
    id: int
    student_id: int
    confidence_score: Optional[float] = None
    image_path: Optional[str] = None
    created_at: datetime

class FaceComparisonRequest(BaseModel):
    """Request model cho so sánh khuôn mặt"""
    image1_path: str
    image2_path: str

class FaceComparisonResponse(BaseModel):
    """Response model cho so sánh khuôn mặt"""
    similarity_score: float
    is_same_person: bool
    threshold: float

class BulkRecognitionRequest(BaseModel):
    """Request model cho nhận diện hàng loạt"""
    images: List[str]  # List of image paths
    location: Optional[str] = None
    device_id: Optional[str] = None

class BulkRecognitionResponse(BaseModel):
    """Response model cho nhận diện hàng loạt"""
    total_images: int
    recognized_faces: int
    unknown_faces: int
    results: dict

class FaceDetectionResult(BaseModel):
    """Model cho kết quả face detection"""
    bounding_box: List[int]  # [x, y, width, height]
    confidence: float
    landmarks: Optional[List[List[float]]] = None  # [[x1, y1], [x2, y2], ...]

class FaceRecognitionResult(BaseModel):
    """Model cho kết quả face recognition"""
    face_detected: bool
    detection_result: Optional[FaceDetectionResult] = None
    student_identified: bool
    student_id: Optional[int] = None
    student_name: Optional[str] = None
    confidence_score: Optional[float] = None
    processing_time_ms: float
