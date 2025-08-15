from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form
from sqlalchemy.orm import Session
from typing import List, Optional
import numpy as np
import cv2
import os
from datetime import datetime

from app.core.database import get_db
from app.core.security import verify_token
from app.services.face_recognition_service import FaceRecognitionService
from app.services.student_service import StudentService
from app.models.face_recognition import (
    FaceRegistrationRequest,
    FaceRegistrationResponse,
    FaceRecognitionRequest,
    FaceRecognitionResponse,
    FaceEmbeddingResponse
)
from app.core.config import settings

router = APIRouter()

@router.post("/register-face", response_model=FaceRegistrationResponse)
async def register_face(
    student_id: int = Form(...),
    images: List[UploadFile] = File(...),
    db: Session = Depends(get_db),
    current_user: dict = Depends(verify_token)
):
    """Đăng ký khuôn mặt cho học sinh"""
    try:
        # Kiểm tra quyền (chỉ admin và teacher mới được đăng ký)
        if current_user.get("role") not in ["admin", "teacher"]:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient permissions"
            )
        
        # Kiểm tra student có tồn tại không
        student_service = StudentService(db)
        student = student_service.get_student_by_id(student_id)
        if not student:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Student not found"
            )
        
        # Kiểm tra số lượng ảnh (3-5 ảnh)
        if len(images) < 3 or len(images) > 5:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Please provide 3-5 images for face registration"
            )
        
        # Xử lý đăng ký khuôn mặt
        face_service = FaceRecognitionService(db)
        result = await face_service.register_face(student_id, images)
        
        return FaceRegistrationResponse(
            student_id=student_id,
            student_name=student.full_name,
            embeddings_count=len(result["embeddings"]),
            confidence_scores=result["confidence_scores"],
            message="Face registration completed successfully"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Face registration failed: {str(e)}"
        )

@router.post("/recognize-face", response_model=FaceRecognitionResponse)
async def recognize_face(
    image: UploadFile = File(...),
    location: Optional[str] = Form(None),
    device_id: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Nhận diện khuôn mặt từ ảnh"""
    try:
        # Kiểm tra file ảnh
        if not image.content_type.startswith("image/"):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="File must be an image"
            )
        
        # Xử lý nhận diện khuôn mặt
        face_service = FaceRecognitionService(db)
        result = await face_service.recognize_face(image, location, device_id)
        
        if result["student_found"]:
            return FaceRecognitionResponse(
                student_id=result["student_id"],
                student_name=result["student_name"],
                confidence_score=result["confidence_score"],
                recognition_time=datetime.now(),
                location=location,
                device_id=device_id,
                status="recognized"
            )
        else:
            return FaceRecognitionResponse(
                student_id=None,
                student_name=None,
                confidence_score=0.0,
                recognition_time=datetime.now(),
                location=location,
                device_id=device_id,
                status="unknown"
            )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Face recognition failed: {str(e)}"
        )

@router.post("/compare-faces")
async def compare_faces(
    image1: UploadFile = File(...),
    image2: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    """So sánh 2 khuôn mặt và trả về độ tương đồng"""
    try:
        # Kiểm tra files
        for img in [image1, image2]:
            if not img.content_type.startswith("image/"):
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Files must be images"
                )
        
        # So sánh khuôn mặt
        face_service = FaceRecognitionService(db)
        similarity_score = await face_service.compare_faces(image1, image2)
        
        return {
            "similarity_score": similarity_score,
            "is_same_person": similarity_score > settings.FACE_RECOGNITION_THRESHOLD,
            "threshold": settings.FACE_RECOGNITION_THRESHOLD
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Face comparison failed: {str(e)}"
        )

@router.get("/student-embeddings/{student_id}", response_model=List[FaceEmbeddingResponse])
async def get_student_embeddings(
    student_id: int,
    db: Session = Depends(get_db),
    current_user: dict = Depends(verify_token)
):
    """Lấy danh sách face embeddings của học sinh"""
    try:
        # Kiểm tra quyền
        if current_user.get("role") not in ["admin", "teacher"]:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient permissions"
            )
        
        # Lấy embeddings
        face_service = FaceRecognitionService(db)
        embeddings = face_service.get_student_embeddings(student_id)
        
        return [
            FaceEmbeddingResponse(
                id=emb.id,
                student_id=emb.student_id,
                confidence_score=emb.confidence_score,
                image_path=emb.image_path,
                created_at=emb.created_at
            )
            for emb in embeddings
        ]
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get embeddings: {str(e)}"
        )

@router.delete("/student-embeddings/{embedding_id}")
async def delete_student_embedding(
    embedding_id: int,
    db: Session = Depends(get_db),
    current_user: dict = Depends(verify_token)
):
    """Xóa face embedding của học sinh"""
    try:
        # Kiểm tra quyền
        if current_user.get("role") not in ["admin", "teacher"]:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient permissions"
            )
        
        # Xóa embedding
        face_service = FaceRecognitionService(db)
        success = face_service.delete_embedding(embedding_id)
        
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Embedding not found"
            )
        
        return {"message": "Embedding deleted successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to delete embedding: {str(e)}"
        )

@router.post("/bulk-recognition")
async def bulk_face_recognition(
    images: List[UploadFile] = File(...),
    location: Optional[str] = Form(None),
    device_id: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    """Nhận diện nhiều khuôn mặt cùng lúc (cho ảnh nhóm)"""
    try:
        # Kiểm tra files
        for img in images:
            if not img.content_type.startswith("image/"):
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="All files must be images"
                )
        
        # Xử lý nhận diện hàng loạt
        face_service = FaceRecognitionService(db)
        results = await face_service.bulk_recognize_faces(images, location, device_id)
        
        return {
            "total_images": len(images),
            "recognized_faces": len(results["recognized"]),
            "unknown_faces": len(results["unknown"]),
            "results": results
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Bulk face recognition failed: {str(e)}"
        )
