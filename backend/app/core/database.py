from sqlalchemy import create_engine, Column, Integer, String, DateTime, Boolean, Text, Float, ForeignKey, JSON, Date
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship
from sqlalchemy.sql import func
from sqlalchemy.dialects.postgresql import ARRAY
from typing import List
import os

from app.core.config import settings

# Tạo engine
engine = create_engine(
    settings.DATABASE_URL,
    pool_size=settings.DATABASE_POOL_SIZE,
    max_overflow=settings.DATABASE_MAX_OVERFLOW,
    echo=settings.DEBUG
)

# Tạo session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base class cho models
Base = declarative_base()

class User(Base):
    """Model cho user (admin, giáo viên)"""
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, index=True, nullable=False)
    email = Column(String(100), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    full_name = Column(String(100), nullable=False)
    role = Column(String(20), default="teacher")  # admin, teacher
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

class Grade(Base):
    __tablename__ = "grades"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, index=True, nullable=False)
    description = Column(Text, nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

class Student(Base):
    """Model cho học sinh"""
    __tablename__ = "students"
    
    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String, nullable=False, index=True)
    email = Column(String, unique=True, nullable=False, index=True)
    grade = Column(String, nullable=False, index=True)
    # section = Column(String, nullable=False, index=True) # Removed section field
    date_of_birth = Column(Date, nullable=True)
    phone = Column(String, nullable=True)
    address = Column(Text, nullable=True)
    parent_name = Column(String, nullable=True)
    parent_phone = Column(String, nullable=True)
    parent_email = Column(String, nullable=True)
    photo_path = Column(String, nullable=True)  # Path to photo for ML
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    # Note: grade field is String, not ForeignKey, so no direct relationship
    # grade_rel = relationship("Grade", back_populates="students")
    face_embeddings = relationship("FaceEmbedding", back_populates="student")
    attendance_records = relationship("AttendanceRecord", back_populates="student")

class FaceEmbedding(Base):
    """Model cho face embedding vectors"""
    __tablename__ = "face_embeddings"
    
    id = Column(Integer, primary_key=True, index=True)
    student_id = Column(Integer, ForeignKey("students.id"), nullable=False)
    embedding_vector = Column(ARRAY(Float), nullable=False)  # PostgreSQL array
    image_path = Column(String(255), nullable=True)
    confidence_score = Column(Float, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    student = relationship("Student", back_populates="face_embeddings")

class AttendanceRecord(Base):
    """Model cho bản ghi điểm danh"""
    __tablename__ = "attendance_records"
    
    id = Column(Integer, primary_key=True, index=True)
    student_id = Column(Integer, ForeignKey("students.id"), nullable=False)
    check_in_time = Column(DateTime(timezone=True), nullable=True)
    check_out_time = Column(DateTime(timezone=True), nullable=True)
    date = Column(DateTime, nullable=False)
    status = Column(String(20), default="present")  # present, absent, late, early_leave
    confidence_score = Column(Float, nullable=True)
    image_path = Column(String(255), nullable=True)
    location = Column(String(100), nullable=True)
    device_id = Column(String(100), nullable=True)
    sync_status = Column(String(20), default="pending")  # pending, synced, failed
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    student = relationship("Student", back_populates="attendance_records")

class Device(Base):
    """Model cho thiết bị điểm danh"""
    __tablename__ = "devices"
    
    id = Column(Integer, primary_key=True, index=True)
    device_id = Column(String(100), unique=True, index=True, nullable=False)
    device_name = Column(String(100), nullable=False)
    location = Column(String(100), nullable=True)
    device_type = Column(String(20), default="camera")  # camera, tablet, mobile
    is_active = Column(Boolean, default=True)
    last_sync = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

class SyncLog(Base):
    """Model cho log đồng bộ dữ liệu"""
    __tablename__ = "sync_logs"
    
    id = Column(Integer, primary_key=True, index=True)
    device_id = Column(String(100), nullable=False)
    sync_type = Column(String(20), nullable=False)  # attendance, student, face_embedding
    records_count = Column(Integer, default=0)
    status = Column(String(20), default="pending")  # pending, success, failed
    error_message = Column(Text, nullable=True)
    started_at = Column(DateTime(timezone=True), server_default=func.now())
    completed_at = Column(DateTime(timezone=True), nullable=True)

# Dependency để lấy database session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
