from sqlalchemy.orm import Session
from typing import List, Optional
from app.core.database import SessionLocal
from app.models.student import StudentCreate, StudentUpdate, StudentResponse
from app.core.database import Student as StudentModel
import logging

logger = logging.getLogger(__name__)

class StudentService:
    """Service class for student management operations"""
    
    def __init__(self):
        pass
    
    async def create_student(self, student_data: StudentCreate) -> StudentResponse:
        """Create a new student"""
        db = SessionLocal()
        try:
            # Check if student with same email already exists
            existing_student = db.query(StudentModel).filter(
                StudentModel.email == student_data.email
            ).first()
            
            if existing_student:
                raise ValueError(f"Student with email '{student_data.email}' already exists")
            
            # Create new student
            db_student = StudentModel(
                full_name=student_data.full_name,
                email=student_data.email,
                grade=student_data.grade,
                # section=student_data.section, # Removed section
                date_of_birth=student_data.date_of_birth,
                phone=student_data.phone,
                address=student_data.address,
                parent_name=student_data.parent_name,
                parent_phone=student_data.parent_phone,
                parent_email=student_data.parent_email,
                photo_path=student_data.photo_path,
            )
            
            db.add(db_student)
            db.commit()
            db.refresh(db_student)
            
            return StudentResponse(
                id=db_student.id,
                full_name=db_student.full_name,
                email=db_student.email,
                grade=db_student.grade,
                # section=db_student.section, # Removed section
                date_of_birth=db_student.date_of_birth,
                phone=db_student.phone,
                address=db_student.address,
                parent_name=db_student.parent_name,
                parent_phone=db_student.parent_phone,
                parent_email=db_student.parent_email,
                photo_path=db_student.photo_path,
                created_at=db_student.created_at,
                updated_at=db_student.updated_at,
            )
            
        except Exception as e:
            db.rollback()
            logger.error(f"Error creating student: {e}")
            raise
        finally:
            db.close()
    
    async def get_students(
        self, 
        skip: int = 0, 
        limit: int = 100,
        grade: Optional[str] = None,
        # section: Optional[str] = None, # Removed section parameter
    ) -> List[StudentResponse]:
        """Get list of students with pagination and filtering"""
        db = SessionLocal()
        try:
            query = db.query(StudentModel)
            
            # Apply filters
            if grade:
                query = query.filter(StudentModel.grade == grade)
            # if section: # Removed section filter
            #     query = query.filter(StudentModel.section == section)
            
            students = query.offset(skip).limit(limit).all()
            
            return [
                StudentResponse(
                    id=student.id,
                    full_name=student.full_name,
                    email=student.email,
                    grade=student.grade,
                    # section=student.section, # Removed section
                    date_of_birth=student.date_of_birth,
                    phone=student.phone,
                    address=student.address,
                    parent_name=student.parent_name,
                    parent_phone=student.parent_phone,
                    parent_email=student.parent_email,
                    photo_path=student.photo_path,
                    created_at=student.created_at,
                    updated_at=student.updated_at,
                )
                for student in students
            ]
            
        except Exception as e:
            logger.error(f"Error fetching students: {e}")
            raise
        finally:
            db.close()
    
    async def get_student(self, student_id: int) -> Optional[StudentResponse]:
        """Get student by ID"""
        db = SessionLocal()
        try:
            student = db.query(StudentModel).filter(StudentModel.id == student_id).first()
            
            if not student:
                return None
            
            return StudentResponse(
                id=student.id,
                full_name=student.full_name,
                email=student.email,
                grade=student.grade,
                # section=student.section, # Removed section
                date_of_birth=student.date_of_birth,
                phone=student.phone,
                address=student.address,
                parent_name=student.parent_name,
                parent_phone=student.parent_phone,
                parent_email=student.parent_email,
                photo_path=student.photo_path,
                created_at=student.created_at,
                updated_at=student.updated_at,
            )
            
        except Exception as e:
            logger.error(f"Error fetching student {student_id}: {e}")
            raise
        finally:
            db.close()
    
    async def update_student(self, student_id: int, student_data: StudentUpdate) -> Optional[StudentResponse]:
        """Update existing student"""
        db = SessionLocal()
        try:
            student = db.query(StudentModel).filter(StudentModel.id == student_id).first()
            
            if not student:
                return None
            
            # Update fields if provided
            if student_data.full_name is not None:
                student.full_name = student_data.full_name
            
            if student_data.email is not None:
                # Check if new email conflicts with existing student
                if student_data.email != student.email:
                    existing_student = db.query(StudentModel).filter(
                        StudentModel.email == student_data.email
                    ).first()
                    
                    if existing_student:
                        raise ValueError(f"Student with email '{student_data.email}' already exists")
                
                student.email = student_data.email
            
            if student_data.grade is not None:
                student.grade = student_data.grade
            
            # if student_data.section is not None: # Removed section update
            #     student.section = student_data.section
            
            if student_data.date_of_birth is not None:
                student.date_of_birth = student_data.date_of_birth
            
            if student_data.phone is not None:
                student.phone = student_data.phone
            
            if student_data.address is not None:
                student.address = student_data.address
            
            if student_data.parent_name is not None:
                student.parent_name = student_data.parent_name
            
            if student_data.parent_phone is not None:
                student.parent_phone = student_data.parent_phone
            
            if student_data.parent_email is not None:
                student.parent_email = student_data.parent_email
            
            if student_data.photo_path is not None:
                student.photo_path = student_data.photo_path
            
            db.commit()
            db.refresh(student)
            
            return StudentResponse(
                id=student.id,
                full_name=student.full_name,
                email=student.email,
                grade=student.grade,
                # section=student.section, # Removed section
                date_of_birth=student.date_of_birth,
                phone=student.phone,
                address=student.address,
                parent_name=student.parent_name,
                parent_phone=student.parent_phone,
                parent_email=student.parent_email,
                photo_path=student.photo_path,
                created_at=student.created_at,
                updated_at=student.updated_at,
            )
            
        except Exception as e:
            db.rollback()
            logger.error(f"Error updating student {student_id}: {e}")
            raise
        finally:
            db.close()
    
    async def delete_student(self, student_id: int) -> bool:
        """Delete student (soft delete by setting is_active to False)"""
        db = SessionLocal()
        try:
            student = db.query(StudentModel).filter(StudentModel.id == student_id).first()
            
            if not student:
                return False
            
            # Soft delete
            student.is_active = False
            db.commit()
            
            return True
            
        except Exception as e:
            db.rollback()
            logger.error(f"Error deleting student {student_id}: {e}")
            raise
        finally:
            db.close()
    
    async def update_student_photo(self, student_id: int, photo_path: str) -> Optional[StudentResponse]:
        """Update student's photo path"""
        db = SessionLocal()
        try:
            student = db.query(StudentModel).filter(StudentModel.id == student_id).first()
            
            if not student:
                return None
            
            student.photo_path = photo_path
            db.commit()
            db.refresh(student)
            
            return StudentResponse(
                id=student.id,
                full_name=student.full_name,
                email=student.email,
                grade=student.grade,
                # section=student.section, # Removed section
                date_of_birth=student.date_of_birth,
                phone=student.phone,
                address=student.address,
                parent_name=student.parent_name,
                parent_phone=student.parent_phone,
                parent_email=student.parent_email,
                photo_path=student.photo_path,
                created_at=student.created_at,
                updated_at=student.updated_at,
            )
            
        except Exception as e:
            db.rollback()
            logger.error(f"Error updating student photo {student_id}: {e}")
            raise
        finally:
            db.close()
    
    async def get_students_by_grade(self, grade: str) -> List[StudentResponse]:
        """Get students by grade"""
        db = SessionLocal()
        try:
            students = db.query(StudentModel).filter(
                StudentModel.grade == grade,
                StudentModel.is_active == True
            ).all()
            
            return [
                StudentResponse(
                    id=student.id,
                    full_name=student.full_name,
                    email=student.email,
                    grade=student.grade,
                    # section=student.section, # Removed section
                    date_of_birth=student.date_of_birth,
                    phone=student.phone,
                    address=student.address,
                    parent_name=student.parent_name,
                    parent_phone=student.parent_phone,
                    parent_email=student.parent_email,
                    photo_path=student.photo_path,
                    created_at=student.created_at,
                    updated_at=student.updated_at,
                )
                for student in students
            ]
            
        except Exception as e:
            logger.error(f"Error fetching students by grade '{grade}': {e}")
            raise
        finally:
            db.close()
    
    async def get_active_students_count(self) -> int:
        """Get count of active students"""
        db = SessionLocal()
        try:
            return db.query(StudentModel).filter(StudentModel.is_active == True).count()
        except Exception as e:
            logger.error(f"Error counting active students: {e}")
            raise
        finally:
            db.close()
