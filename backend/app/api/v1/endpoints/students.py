from fastapi import APIRouter, HTTPException, Depends, UploadFile, File, Form
from fastapi.responses import FileResponse
from typing import List, Optional
import os
import shutil
from datetime import datetime
import uuid
import time
import logging

from app.models.student import StudentCreate, StudentUpdate, StudentResponse
from app.models.face_recognition import FaceRegistrationRequest, FaceRegistrationResponse
from app.core.security import get_current_user
from app.services.student_service import StudentService
from app.services.face_recognition_service import FaceRecognitionService

router = APIRouter()
student_service = StudentService()
face_recognition_service = FaceRecognitionService()

# Cấu hình upload
UPLOAD_DIR = "uploads/students"
ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp"}
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB

# Tạo thư mục upload nếu chưa có
os.makedirs(UPLOAD_DIR, exist_ok=True)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@router.post("/", response_model=StudentResponse)
async def create_student(
    student_data: StudentCreate,
    # current_user: dict = Depends(get_current_user)  # Temporarily disabled for testing
):
    """Tạo student mới"""
    try:
        student = await student_service.create_student(student_data)
        return student
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/with-photos", response_model=StudentResponse, summary="Create student with multiple photos for ML")
async def create_student_with_photos(
    name: str = Form(...),
    email: Optional[str] = Form(None),  # Đổi thành optional
    grade: str = Form(...),
    # section: str = Form(...), # Removed section parameter
    date_of_birth: Optional[str] = Form(None),
    phone: Optional[str] = Form(None),
    address: Optional[str] = Form(None),
    parent_name: Optional[str] = Form(None),
    parent_phone: Optional[str] = Form(None),
    parent_email: Optional[str] = Form(None),
    photos: List[UploadFile] = File(...),
    # current_user: dict = Depends(get_current_user)  # Temporarily disabled for testing
):
    """
    Create a new student with multiple photos for ML face recognition.
    
    - **name**: Student's full name
    - **email**: Student's email address (optional)
    - **grade**: Student's grade level
    - **photos**: List of photos for ML face recognition (3-5 recommended)
    - **date_of_birth**: Student's date of birth (optional)
    - **phone**: Student's phone number (optional)
    - **address**: Student's address (optional)
    - **parent_name**: Parent's name (optional)
    - **parent_phone**: Parent's phone number (optional)
    - **parent_email**: Parent's email address (optional)
    """
    try:
        # Validate photo count
        if len(photos) < 1:
            raise HTTPException(
                status_code=400, 
                detail="At least one photo is required for ML face recognition"
            )
        
        if len(photos) > 10:
            raise HTTPException(
                status_code=400, 
                detail="Maximum 10 photos allowed"
            )
        
        # Prepare student data
        student_data = StudentCreate(
            full_name=name,
            email=email if email else None,  # Xử lý email optional
            grade=grade,
            # section=section, # Removed section
            date_of_birth=date_of_birth,
            phone=phone,
            address=address,
            parent_name=parent_name,
            parent_phone=parent_phone,
            parent_email=parent_email,
        )
        
        # Create student
        student = await student_service.create_student(student_data)
        
        # Save photos and trigger ML
        photo_paths = []
        for i, photo in enumerate(photos):
            # Save photo to uploads directory
            photo_filename = f"student_{student.id}_photo_{i}_{int(time.time())}.jpg"
            photo_path = f"uploads/students/{photo_filename}"
            
            # Ensure directory exists
            os.makedirs(os.path.dirname(photo_path), exist_ok=True)
            
            # Save photo
            with open(photo_path, "wb") as buffer:
                content = await photo.read()
                buffer.write(content)
            
            photo_paths.append(photo_path)
            
            # Trigger ML face recognition for each photo
            try:
                await face_recognition_service.register_face(
                    student_id=student.id,
                    image_path=photo_path
                )
            except Exception as e:
                logger.warning(f"ML face recognition failed for photo {i}: {e}")
        
        # Update student with first photo path
        if photo_paths:
            await student_service.update_student_photo(student.id, photo_paths[0])
        
        return student
        
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Error creating student with photos: {e}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

@router.get("/", response_model=List[StudentResponse])
async def get_students(
    skip: int = 0,
    limit: int = 100,
    grade: Optional[str] = None,
    # current_user: dict = Depends(get_current_user)  # Temporarily disabled for testing
):
    """Lấy danh sách students với filter"""
    try:
        students = await student_service.get_students(skip=skip, limit=limit, grade=grade)
        return students
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/{student_id}", response_model=StudentResponse)
async def get_student(
    student_id: int,
    # current_user: dict = Depends(get_current_user)  # Temporarily disabled for testing
):
    """Lấy thông tin student theo ID"""
    try:
        student = await student_service.get_student(student_id)
        if not student:
            raise HTTPException(status_code=404, detail="Student not found")
        return student
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/code/{student_code}", response_model=StudentResponse)
async def get_student_by_code(
    student_code: str,
    # current_user: dict = Depends(get_current_user)  # Temporarily disabled for testing
):
    """Lấy thông tin student theo mã student"""
    try:
        student = await student_service.get_student_by_code(student_code)
        if not student:
            raise HTTPException(status_code=404, detail="Student not found")
        return student
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.put("/{student_id}", response_model=StudentResponse)
async def update_student(
    student_id: int,
    student_data: StudentUpdate,
    current_user: dict = Depends(get_current_user)
):
    """Cập nhật thông tin student"""
    try:
        student = await student_service.update_student(student_id, student_data)
        if not student:
            raise HTTPException(status_code=404, detail="Student not found")
        return student
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.delete("/{student_id}")
async def delete_student(
    student_id: int,
    # current_user: dict = Depends(get_current_user)  # Temporarily disabled for testing
):
    """Xóa student"""
    try:
        success = await student_service.delete_student(student_id)
        if not success:
            raise HTTPException(status_code=404, detail="Student not found")
        return {"message": "Student deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/photo/{filename}")
async def get_student_photo(filename: str):
    """Lấy ảnh student"""
    file_path = os.path.join(UPLOAD_DIR, filename)
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="Photo not found")
    return FileResponse(file_path)

@router.post("/{student_id}/upload-photos")
async def upload_student_photos(
    student_id: int,
    photos: List[UploadFile] = File(...),
    # current_user: dict = Depends(get_current_user)  # Temporarily disabled for testing
):
    """Upload nhiều ảnh cho student"""
    try:
        # Validate photos
        if not photos or len(photos) < 1:
            raise HTTPException(
                status_code=400, 
                detail="At least 1 photo is required"
            )
        
        if len(photos) > 5:
            raise HTTPException(
                status_code=400, 
                detail="Maximum 5 photos allowed"
            )
        
        saved_image_paths = []
        
        # Process each photo
        for i, photo in enumerate(photos):
            if not photo.filename:
                raise HTTPException(status_code=400, detail=f"No filename for photo {i+1}")
            
            file_ext = os.path.splitext(photo.filename)[1].lower()
            if file_ext not in ALLOWED_EXTENSIONS:
                raise HTTPException(
                    status_code=400, 
                    detail=f"Invalid file type for photo {i+1}. Allowed: {', '.join(ALLOWED_EXTENSIONS)}"
                )
            
            # Generate unique filename
            file_id = str(uuid.uuid4())
            filename = f"{file_id}{file_ext}"
            file_path = os.path.join(UPLOAD_DIR, filename)
            
            # Save file
            with open(file_path, "wb") as buffer:
                shutil.copyfileobj(photo.file, buffer)
            
            saved_image_paths.append(file_path)
        
        # Update student photo path (primary photo)
        student = await student_service.update_student_photo(student_id, saved_image_paths[0])
        if not student:
            raise HTTPException(status_code=404, detail="Student not found")
        
        # Register faces for ML
        try:
            face_request = FaceRegistrationRequest(
                student_id=student_id,
                images_count=len(saved_image_paths)
            )
            
            for image_path in saved_image_paths:
                await face_recognition_service.register_face(face_request, image_path)
            
            print(f"ML: Registered {len(saved_image_paths)} new faces for student {student_id}")
            
        except Exception as e:
            print(f"Face registration failed: {e}")
        
        return {
            "message": f"{len(saved_image_paths)} photos uploaded successfully", 
            "photo_paths": saved_image_paths
        }
        
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
