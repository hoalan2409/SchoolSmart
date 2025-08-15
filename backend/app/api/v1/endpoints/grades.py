from fastapi import APIRouter, Depends, HTTPException, Query
from typing import List
from app.models.grade import GradeCreate, GradeUpdate, GradeResponse, GradeListResponse
from app.services.grade_service import GradeService
from app.core.security import get_current_user

router = APIRouter()
grade_service = GradeService()

@router.post("/", response_model=GradeResponse, summary="Create new grade")
async def create_grade(
    grade_data: GradeCreate,
    # current_user: dict = Depends(get_current_user)  # Temporarily disabled for testing
):
    """
    Create a new grade.
    
    - **name**: Grade name (e.g., Grade 10, Grade 11)
    - **description**: Optional description
    - **is_active**: Whether the grade is active
    """
    try:
        grade = await grade_service.create_grade(grade_data)
        return grade
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

@router.get("/", response_model=List[GradeResponse], summary="Get all grades")
async def get_grades(
    skip: int = Query(0, ge=0, description="Number of records to skip"),
    limit: int = Query(100, ge=1, le=1000, description="Number of records to return"),
    active_only: bool = Query(True, description="Return only active grades")
):
    """
    Get list of grades with pagination.
    
    - **skip**: Number of records to skip (for pagination)
    - **limit**: Number of records to return (max 1000)
    - **active_only**: Whether to return only active grades
    """
    try:
        grades = await grade_service.get_grades(skip=skip, limit=limit, active_only=active_only)
        return grades
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

@router.get("/{grade_id}", response_model=GradeResponse, summary="Get grade by ID")
async def get_grade(
    grade_id: int,
    current_user: dict = Depends(get_current_user)
):
    """
    Get grade details by ID.
    
    - **grade_id**: The ID of the grade to retrieve
    """
    try:
        grade = await grade_service.get_grade(grade_id)
        if not grade:
            raise HTTPException(status_code=404, detail="Grade not found")
        return grade
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

@router.put("/{grade_id}", response_model=GradeResponse, summary="Update grade")
async def update_grade(
    grade_id: int,
    grade_data: GradeUpdate,
    current_user: dict = Depends(get_current_user)
):
    """
    Update existing grade information.
    
    - **grade_id**: The ID of the grade to update
    - **grade_data**: Updated grade information
    """
    try:
        grade = await grade_service.update_grade(grade_id, grade_data)
        if not grade:
            raise HTTPException(status_code=404, detail="Grade not found")
        return grade
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

@router.delete("/{grade_id}", summary="Delete grade")
async def delete_grade(
    grade_id: int,
    current_user: dict = Depends(get_current_user)
):
    """
    Delete grade (soft delete).
    
    - **grade_id**: The ID of the grade to delete
    
    Note: Grades with students cannot be deleted.
    """
    try:
        success = await grade_service.delete_grade(grade_id)
        if not success:
            raise HTTPException(status_code=404, detail="Grade not found")
        return {"message": "Grade deleted successfully"}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

@router.get("/name/{grade_name}", response_model=GradeResponse, summary="Get grade by name")
async def get_grade_by_name(
    grade_name: str,
    current_user: dict = Depends(get_current_user)
):
    """
    Get grade details by name.
    
    - **grade_name**: The name of the grade to retrieve
    """
    try:
        grade = await grade_service.get_grade_by_name(grade_name)
        if not grade:
            raise HTTPException(status_code=404, detail="Grade not found")
        return grade
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

@router.get("/stats/count", summary="Get grade statistics")
async def get_grade_stats(
    current_user: dict = Depends(get_current_user)
):
    """
    Get grade statistics.
    
    Returns:
    - **total_grades**: Total number of grades
    - **active_grades**: Number of active grades
    """
    try:
        active_count = await grade_service.get_active_grades_count()
        # TODO: Add total count method if needed
        return {
            "active_grades": active_count,
            "message": "Grade statistics retrieved successfully"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")
