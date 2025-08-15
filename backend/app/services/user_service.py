from sqlalchemy.orm import Session
from app.core.database import User
from app.core.security import get_password_hash, verify_password
from app.models.user import UserCreate, UserUpdate
from typing import Optional, List
import logging

logger = logging.getLogger(__name__)

class UserService:
    """Service class để xử lý business logic cho User"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def get_user_by_id(self, user_id: int) -> Optional[User]:
        """Lấy user theo ID"""
        try:
            return self.db.query(User).filter(User.id == user_id).first()
        except Exception as e:
            logger.error(f"Error getting user by ID {user_id}: {e}")
            return None
    
    def get_user_by_username(self, username: str) -> Optional[User]:
        """Lấy user theo username"""
        try:
            return self.db.query(User).filter(User.username == username).first()
        except Exception as e:
            logger.error(f"Error getting user by username {username}: {e}")
            return None
    
    def get_user_by_email(self, email: str) -> Optional[User]:
        """Lấy user theo email"""
        try:
            return self.db.query(User).filter(User.email == email).first()
        except Exception as e:
            logger.error(f"Error getting user by email {email}: {e}")
            return None
    
    def get_users(self, skip: int = 0, limit: int = 100) -> List[User]:
        """Lấy danh sách users với pagination"""
        try:
            return self.db.query(User).offset(skip).limit(limit).all()
        except Exception as e:
            logger.error(f"Error getting users: {e}")
            return []
    
    def create_user(self, user_data: UserCreate) -> User:
        """Tạo user mới"""
        try:
            # Hash password
            hashed_password = get_password_hash(user_data.password)
            
            # Tạo user object
            db_user = User(
                username=user_data.username,
                email=user_data.email,
                full_name=user_data.full_name,
                role=user_data.role,
                hashed_password=hashed_password
            )
            
            # Lưu vào database
            self.db.add(db_user)
            self.db.commit()
            self.db.refresh(db_user)
            
            logger.info(f"Created new user: {user_data.username}")
            return db_user
            
        except Exception as e:
            self.db.rollback()
            logger.error(f"Error creating user {user_data.username}: {e}")
            raise
    
    def update_user(self, user_id: int, user_data: UserUpdate) -> Optional[User]:
        """Cập nhật user"""
        try:
            db_user = self.get_user_by_id(user_id)
            if not db_user:
                return None
            
            # Cập nhật các field được cung cấp
            update_data = user_data.dict(exclude_unset=True)
            
            # Hash password nếu có cập nhật
            if "password" in update_data:
                update_data["hashed_password"] = get_password_hash(update_data.pop("password"))
            
            # Cập nhật từng field
            for field, value in update_data.items():
                setattr(db_user, field, value)
            
            self.db.commit()
            self.db.refresh(db_user)
            
            logger.info(f"Updated user: {db_user.username}")
            return db_user
            
        except Exception as e:
            self.db.rollback()
            logger.error(f"Error updating user {user_id}: {e}")
            raise
    
    def delete_user(self, user_id: int) -> bool:
        """Xóa user (soft delete)"""
        try:
            db_user = self.get_user_by_id(user_id)
            if not db_user:
                return False
            
            # Soft delete - chỉ set is_active = False
            db_user.is_active = False
            self.db.commit()
            
            logger.info(f"Deleted user: {db_user.username}")
            return True
            
        except Exception as e:
            self.db.rollback()
            logger.error(f"Error deleting user {user_id}: {e}")
            return False
    
    def authenticate_user(self, username: str, password: str) -> Optional[User]:
        """Xác thực user với username và password"""
        try:
            user = self.get_user_by_username(username)
            if not user:
                return None
            
            if not verify_password(password, user.hashed_password):
                return None
            
            return user
            
        except Exception as e:
            logger.error(f"Error authenticating user {username}: {e}")
            return None
    
    def change_password(self, user_id: int, old_password: str, new_password: str) -> bool:
        """Thay đổi password của user"""
        try:
            user = self.get_user_by_id(user_id)
            if not user:
                return False
            
            # Xác thực password cũ
            if not verify_password(old_password, user.hashed_password):
                return False
            
            # Hash password mới
            user.hashed_password = get_password_hash(new_password)
            self.db.commit()
            
            logger.info(f"Changed password for user: {user.username}")
            return True
            
        except Exception as e:
            self.db.rollback()
            logger.error(f"Error changing password for user {user_id}: {e}")
            return False
    
    def get_active_users(self) -> List[User]:
        """Lấy danh sách users đang active"""
        try:
            return self.db.query(User).filter(User.is_active == True).all()
        except Exception as e:
            logger.error(f"Error getting active users: {e}")
            return []
    
    def get_users_by_role(self, role: str) -> List[User]:
        """Lấy danh sách users theo role"""
        try:
            return self.db.query(User).filter(User.role == role, User.is_active == True).all()
        except Exception as e:
            logger.error(f"Error getting users by role {role}: {e}")
            return []
