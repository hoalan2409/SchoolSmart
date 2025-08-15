from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import date

from app.core.database import get_db
from app.core.security import verify_token
from app.services.student_service import StudentService
from app.models.student import StudentCreate, StudentUpdate, StudentResponse

router = APIRouter()

@router.get("/", response_model=List[StudentResponse])
async def get_students(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    search: Optional[str] = Query(None),
    class_name: Optional[str] = Query(None),
    db: Session = Depends(get_db),
    current_user: dict = Depends(verify_token)
):
    """Lấy danh sách học sinh"""
    try:
        student_service = StudentService(db)
        
        if search:
            students = student_service.search_students(search)
        elif class_name:
            students = student_service.get_students_by_class(class_name)
        else:
            students = student_service.get_students(skip=skip, limit=limit)
        
        return students
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch students: {str(e)}"
        )

@router.get("/{student_id}", response_model=StudentResponse)
async def get_student(
    student_id: int,
    db: Session = Depends(get_db),
    current_user: dict = Depends(verify_token)
):
    """Lấy thông tin học sinh theo ID"""
    try:
        student_service = StudentService(db)
        student = student_service.get_student(student_id)
        
        if not student:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Student not found"
            )
        
        return student
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch student: {str(e)}"
        )

@router.post("/", response_model=StudentResponse)
async def create_student(
    student: StudentCreate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(verify_token)
):
    """Tạo học sinh mới"""
    try:
        # Kiểm tra quyền (chỉ admin và teacher mới được tạo)
        if current_user.get("role") not in ["admin", "teacher"]:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient permissions"
            )
        
        student_service = StudentService(db)
        
        # Kiểm tra mã học sinh đã tồn tại chưa
        existing_student = student_service.get_student_by_code(student.student_code)
        if existing_student:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Student code already exists"
            )
        
        new_student = student_service.create_student(student)
        return new_student
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create student: {str(e)}"
        )

@router.put("/{student_id}", response_model=StudentResponse)
async def update_student(
    student_id: int,
    student: StudentUpdate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(verify_token)
):
    """Cập nhật thông tin học sinh"""
    try:
        # Kiểm tra quyền
        if current_user.get("role") not in ["admin", "teacher"]:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient permissions"
            )
        
        student_service = StudentService(db)
        updated_student = student_service.update_student(student_id, student)
        
        if not updated_student:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Student not found"
            )
        
        return updated_student
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update student: {str(e)}"
        )

@router.delete("/{student_id}")
async def delete_student(
    student_id: int,
    db: Session = Depends(get_db),
    current_user: dict = Depends(verify_token)
):
    """Xóa học sinh"""
    try:
        # Kiểm tra quyền (chỉ admin mới được xóa)
        if current_user.get("role") != "admin":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only admin can delete students"
            )
        
        student_service = StudentService(db)
        success = student_service.delete_student(student_id)
        
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Student not found"
            )
        
        return {"message": "Student deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to delete student: {str(e)}"
        )

@router.get("/stats/count")
async def get_student_count(
    db: Session = Depends(get_db),
    current_user: dict = Depends(verify_token)
):
    """Lấy tổng số học sinh"""
    try:
        student_service = StudentService(db)
        count = student_service.get_student_count()
        return {"total_students": count}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get student count: {str(e)}"
        )
