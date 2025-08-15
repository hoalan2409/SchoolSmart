from fastapi import APIRouter
from app.api.v1.endpoints import auth, students, attendance, face_recognition, sync, grades

api_router = APIRouter()

# Include các endpoint routers
api_router.include_router(auth.router, prefix="/auth", tags=["authentication"])
api_router.include_router(students.router, prefix="/students", tags=["students"])
api_router.include_router(attendance.router, prefix="/attendance", tags=["attendance"])
api_router.include_router(face_recognition.router, prefix="/face-recognition", tags=["face recognition"])
api_router.include_router(sync.router, prefix="/sync", tags=["synchronization"])
api_router.include_router(grades.router, prefix="/grades", tags=["grades"])
