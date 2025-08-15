from typing import List, Optional
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.database import Student, FaceEmbedding
from app.models.student import StudentCreate, StudentUpdate, StudentResponse
from fastapi import Depends, HTTPException, status
import numpy as np

class StudentService:
    def __init__(self, db: Session = Depends(get_db)):
        self.db = db

    def get_students(self, skip: int = 0, limit: int = 100) -> List[Student]:
        """Lấy danh sách học sinh"""
        return self.db.query(Student).offset(skip).limit(limit).all()

    def get_student(self, student_id: int) -> Optional[Student]:
        """Lấy thông tin học sinh theo ID"""
        return self.db.query(Student).filter(Student.id == student_id).first()

    def get_student_by_id(self, student_id: int) -> Optional[Student]:
        """Lấy thông tin học sinh theo ID (alias cho get_student)"""
        return self.get_student(student_id)

    def get_student_by_code(self, student_code: str) -> Optional[Student]:
        """Lấy thông tin học sinh theo mã học sinh"""
        return self.db.query(Student).filter(Student.student_code == student_code).first()

    def create_student(self, student: StudentCreate) -> Student:
        """Tạo học sinh mới"""
        db_student = Student(
            student_code=student.student_code,
            full_name=student.full_name,
            date_of_birth=student.date_of_birth,
            gender=student.gender,
            class_name=student.class_name,
            email=student.email,
            phone=student.phone,
            address=student.address
        )
        self.db.add(db_student)
        self.db.commit()
        self.db.refresh(db_student)
        return db_student

    def update_student(self, student_id: int, student: StudentUpdate) -> Optional[Student]:
        """Cập nhật thông tin học sinh"""
        db_student = self.get_student(student_id)
        if not db_student:
            return None
        
        update_data = student.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(db_student, field, value)
        
        self.db.commit()
        self.db.refresh(db_student)
        return db_student

    def delete_student(self, student_id: int) -> bool:
        """Xóa học sinh"""
        db_student = self.get_student(student_id)
        if not db_student:
            return False
        
        self.db.delete(db_student)
        self.db.commit()
        return True

    def search_students(self, query: str) -> List[Student]:
        """Tìm kiếm học sinh theo tên hoặc mã"""
        return self.db.query(Student).filter(
            (Student.full_name.contains(query)) | 
            (Student.student_code.contains(query))
        ).all()

    def get_student_face_embeddings(self, student_id: int) -> List[FaceEmbedding]:
        """Lấy face embeddings của học sinh"""
        return self.db.query(FaceEmbedding).filter(
            FaceEmbedding.student_id == student_id
        ).all()

    def add_face_embedding(self, student_id: int, embedding: np.ndarray, image_path: str) -> FaceEmbedding:
        """Thêm face embedding cho học sinh"""
        # Convert numpy array to bytes for storage
        embedding_bytes = embedding.tobytes()
        
        db_embedding = FaceEmbedding(
            student_id=student_id,
            embedding=embedding_bytes,
            image_path=image_path
        )
        self.db.add(db_embedding)
        self.db.commit()
        self.db.refresh(db_embedding)
        return db_embedding

    def get_student_count(self) -> int:
        """Đếm tổng số học sinh"""
        return self.db.query(Student).count()

    def get_students_by_class(self, class_name: str) -> List[Student]:
        """Lấy danh sách học sinh theo lớp"""
        return self.db.query(Student).filter(Student.class_name == class_name).all()
