from sqlalchemy.orm import Session
from sqlalchemy import and_
from typing import List, Optional
from app.core.database import SessionLocal
from app.models.grade import GradeCreate, GradeUpdate, GradeResponse
from app.core.database import Grade as GradeModel
import logging

logger = logging.getLogger(__name__)

class GradeService:
    """Service class for grade management operations"""
    
    def __init__(self):
        pass
    
    async def create_grade(self, grade_data: GradeCreate) -> GradeResponse:
        """Create a new grade"""
        db = SessionLocal()
        try:
            # Check if grade name already exists
            existing_grade = db.query(GradeModel).filter(
                GradeModel.name == grade_data.name
            ).first()
            
            if existing_grade:
                raise ValueError(f"Grade with name '{grade_data.name}' already exists")
            
            # Create new grade
            db_grade = GradeModel(
                name=grade_data.name,
                description=grade_data.description,
                is_active=grade_data.is_active,
            )
            
            db.add(db_grade)
            db.commit()
            db.refresh(db_grade)
            
            return GradeResponse(
                id=db_grade.id,
                name=db_grade.name,
                description=db_grade.description,
                is_active=db_grade.is_active,
                created_at=db_grade.created_at,
                updated_at=db_grade.updated_at,
            )
            
        except Exception as e:
            db.rollback()
            logger.error(f"Error creating grade: {e}")
            raise
        finally:
            db.close()
    
    async def get_grades(
        self, 
        skip: int = 0, 
        limit: int = 100,
        active_only: bool = True
    ) -> List[GradeResponse]:
        """Get list of grades with pagination"""
        db = SessionLocal()
        try:
            query = db.query(GradeModel)
            
            if active_only:
                query = query.filter(GradeModel.is_active == True)
            
            # Order by name for logical sorting
            query = query.order_by(GradeModel.name)
            
            grades = query.offset(skip).limit(limit).all()
            
            return [
                GradeResponse(
                    id=grade.id,
                    name=grade.name,
                    description=grade.description,
                    is_active=grade.is_active,
                    created_at=grade.created_at,
                    updated_at=grade.updated_at,
                )
                for grade in grades
            ]
            
        except Exception as e:
            logger.error(f"Error fetching grades: {e}")
            raise
        finally:
            db.close()
    
    async def get_grade(self, grade_id: int) -> Optional[GradeResponse]:
        """Get grade by ID"""
        db = SessionLocal()
        try:
            grade = db.query(GradeModel).filter(GradeModel.id == grade_id).first()
            
            if not grade:
                return None
            
            return GradeResponse(
                id=grade.id,
                name=grade.name,
                description=grade.description,
                is_active=grade.is_active,
                created_at=grade.created_at,
                updated_at=grade.updated_at,
            )
            
        except Exception as e:
            logger.error(f"Error fetching grade {grade_id}: {e}")
            raise
        finally:
            db.close()
    
    async def update_grade(self, grade_id: int, grade_data: GradeUpdate) -> Optional[GradeResponse]:
        """Update existing grade"""
        db = SessionLocal()
        try:
            grade = db.query(GradeModel).filter(GradeModel.id == grade_id).first()
            
            if not grade:
                return None
            
            # Update fields if provided
            if grade_data.name is not None:
                # Check if new name conflicts with existing grade
                if grade_data.name != grade.name:
                    existing_grade = db.query(GradeModel).filter(
                        and_(
                            GradeModel.name == grade_data.name,
                            GradeModel.id != grade_id
                        )
                    ).first()
                    
                    if existing_grade:
                        raise ValueError(f"Grade with name '{grade_data.name}' already exists")
                
                grade.name = grade_data.name
            
            if grade_data.description is not None:
                grade.description = grade_data.description
            

            
            if grade_data.is_active is not None:
                grade.is_active = grade_data.is_active
            
            db.commit()
            db.refresh(grade)
            
            return GradeResponse(
                id=grade.id,
                name=grade.name,
                description=grade.description,
                is_active=grade.is_active,
                created_at=grade.created_at,
                updated_at=grade.updated_at,
            )
            
        except Exception as e:
            db.rollback()
            logger.error(f"Error updating grade {grade_id}: {e}")
            raise
        finally:
            db.close()
    
    async def delete_grade(self, grade_id: int) -> bool:
        """Delete grade (soft delete by setting is_active to False)"""
        db = SessionLocal()
        try:
            grade = db.query(GradeModel).filter(GradeModel.id == grade_id).first()
            
            if not grade:
                return False
            
            # Note: Students reference grade by name, not by foreign key
            # So we can't directly check if grade has students
            # This would need a separate query to check
            
            # Soft delete
            grade.is_active = False
            db.commit()
            
            return True
            
        except Exception as e:
            db.rollback()
            logger.error(f"Error deleting grade {grade_id}: {e}")
            raise
        finally:
            db.close()
    
    async def get_grade_by_name(self, name: str) -> Optional[GradeResponse]:
        """Get grade by name"""
        db = SessionLocal()
        try:
            grade = db.query(GradeModel).filter(GradeModel.name == name).first()
            
            if not grade:
                return None
            
            return GradeResponse(
                id=grade.id,
                name=grade.name,
                description=grade.description,
                is_active=grade.is_active,
                created_at=grade.created_at,
                updated_at=grade.updated_at,
            )
            
        except Exception as e:
            logger.error(f"Error fetching grade by name '{name}': {e}")
            raise
        finally:
            db.close()
    
    async def get_active_grades_count(self) -> int:
        """Get count of active grades"""
        db = SessionLocal()
        try:
            return db.query(GradeModel).filter(GradeModel.is_active == True).count()
        except Exception as e:
            logger.error(f"Error counting active grades: {e}")
            raise
        finally:
            db.close()
