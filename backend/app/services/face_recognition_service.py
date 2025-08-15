import cv2
import numpy as np
import insightface
from insightface.app import FaceAnalysis
import onnxruntime as ort
import os
import logging
from typing import List, Dict, Optional, Tuple
from sqlalchemy.orm import Session
import aiofiles
from datetime import datetime
import uuid

from app.core.database import FaceEmbedding, Student
from app.core.config import settings

logger = logging.getLogger(__name__)

class FaceRecognitionService:
    """Service class để xử lý AI face recognition"""
    
    def __init__(self, db: Session):
        self.db = db
        self.face_analyzer = None
        self.face_detector = None
        self.face_recognizer = None
        self._initialize_models()
    
    def _initialize_models(self):
        """Khởi tạo các AI models"""
        try:
            # Khởi tạo InsightFace app
            self.face_analyzer = FaceAnalysis(
                name='buffalo_l',
                providers=['CPUExecutionProvider']
            )
            self.face_analyzer.prepare(ctx_id=0, det_size=(640, 640))
            
            logger.info("AI models initialized successfully")
            
        except Exception as e:
            logger.error(f"Failed to initialize AI models: {e}")
            # Fallback to basic models
            self._initialize_fallback_models()
    
    def _initialize_fallback_models(self):
        """Khởi tạo fallback models nếu InsightFace không hoạt động"""
        try:
            # Sử dụng OpenCV face detection
            self.face_detector = cv2.CascadeClassifier(
                cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'
            )
            logger.info("Fallback models initialized")
        except Exception as e:
            logger.error(f"Failed to initialize fallback models: {e}")
    
    async def register_face(self, student_id: int, images: List) -> Dict:
        """Đăng ký khuôn mặt cho học sinh"""
        try:
            embeddings = []
            confidence_scores = []
            
            for i, image in enumerate(images):
                # Đọc và xử lý ảnh
                image_data = await self._read_image_file(image)
                if image_data is None:
                    continue
                
                # Face detection
                faces = self._detect_faces(image_data)
                if not faces:
                    logger.warning(f"No face detected in image {i+1}")
                    continue
                
                # Lấy khuôn mặt đầu tiên (giả sử mỗi ảnh chỉ có 1 khuôn mặt)
                face = faces[0]
                
                # Tạo embedding
                embedding = self._extract_face_embedding(image_data, face)
                if embedding is not None:
                    # Lưu embedding vào database
                    db_embedding = FaceEmbedding(
                        student_id=student_id,
                        embedding_vector=embedding.tolist(),
                        confidence_score=face.get('confidence', 0.8),
                        image_path=f"uploads/student_{student_id}/face_{i+1}_{uuid.uuid4()}.jpg"
                    )
                    
                    self.db.add(db_embedding)
                    embeddings.append(embedding)
                    confidence_scores.append(face.get('confidence', 0.8))
                    
                    # Lưu ảnh
                    await self._save_image(image, db_embedding.image_path)
            
            # Commit tất cả embeddings
            self.db.commit()
            
            return {
                "embeddings": embeddings,
                "confidence_scores": confidence_scores,
                "success": True
            }
            
        except Exception as e:
            self.db.rollback()
            logger.error(f"Face registration failed: {e}")
            raise
    
    async def recognize_face(self, image, location: str = None, device_id: str = None) -> Dict:
        """Nhận diện khuôn mặt từ ảnh"""
        try:
            # Đọc và xử lý ảnh
            image_data = await self._read_image_file(image)
            if image_data is None:
                return {"student_found": False, "error": "Invalid image"}
            
            # Face detection
            faces = self._detect_faces(image_data)
            if not faces:
                return {"student_found": False, "error": "No face detected"}
            
            # Lấy khuôn mặt đầu tiên
            face = faces[0]
            
            # Tạo embedding cho ảnh hiện tại
            current_embedding = self._extract_face_embedding(image_data, face)
            if current_embedding is None:
                return {"student_found": False, "error": "Failed to extract face features"}
            
            # So sánh với database
            best_match = self._find_best_match(current_embedding)
            
            if best_match and best_match['similarity'] > settings.FACE_RECOGNITION_THRESHOLD:
                # Lấy thông tin học sinh
                student = self.db.query(Student).filter(Student.id == best_match['student_id']).first()
                
                return {
                    "student_found": True,
                    "student_id": student.id,
                    "student_name": student.full_name,
                    "confidence_score": best_match['similarity'],
                    "location": location,
                    "device_id": device_id
                }
            else:
                return {
                    "student_found": False,
                    "error": "No matching student found"
                }
                
        except Exception as e:
            logger.error(f"Face recognition failed: {e}")
            return {"student_found": False, "error": str(e)}
    
    async def compare_faces(self, image1, image2) -> float:
        """So sánh 2 khuôn mặt và trả về độ tương đồng"""
        try:
            # Đọc ảnh
            img1_data = await self._read_image_file(image1)
            img2_data = await self._read_image_file(image2)
            
            if img1_data is None or img2_data is None:
                return 0.0
            
            # Face detection
            faces1 = self._detect_faces(img1_data)
            faces2 = self._detect_faces(img2_data)
            
            if not faces1 or not faces2:
                return 0.0
            
            # Tạo embeddings
            embedding1 = self._extract_face_embedding(img1_data, faces1[0])
            embedding2 = self._extract_face_embedding(img2_data, faces2[0])
            
            if embedding1 is None or embedding2 is None:
                return 0.0
            
            # Tính cosine similarity
            similarity = self._cosine_similarity(embedding1, embedding2)
            return float(similarity)
            
        except Exception as e:
            logger.error(f"Face comparison failed: {e}")
            return 0.0
    
    def _detect_faces(self, image: np.ndarray) -> List[Dict]:
        """Phát hiện khuôn mặt trong ảnh"""
        try:
            if self.face_analyzer:
                # Sử dụng InsightFace
                faces = self.face_analyzer.get(image)
                return [
                    {
                        'bbox': face.bbox,
                        'kps': face.kps,
                        'confidence': face.det_score
                    }
                    for face in faces
                ]
            elif self.face_detector:
                # Fallback to OpenCV
                gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
                faces = self.face_detector.detectMultiScale(
                    gray, 
                    scaleFactor=1.1, 
                    minNeighbors=5,
                    minSize=(30, 30)
                )
                
                return [
                    {
                        'bbox': [x, y, w, h],
                        'confidence': 0.8  # Default confidence for OpenCV
                    }
                    for (x, y, w, h) in faces
                ]
            else:
                return []
                
        except Exception as e:
            logger.error(f"Face detection failed: {e}")
            return []
    
    def _extract_face_embedding(self, image: np.ndarray, face: Dict) -> Optional[np.ndarray]:
        """Trích xuất face embedding vector"""
        try:
            if self.face_analyzer:
                # Sử dụng InsightFace
                bbox = face['bbox']
                x1, y1, x2, y2 = int(bbox[0]), int(bbox[1]), int(bbox[2]), int(bbox[3])
                
                # Crop khuôn mặt
                face_img = image[y1:y2, x1:x2]
                if face_img.size == 0:
                    return None
                
                # Resize về kích thước chuẩn
                face_img = cv2.resize(face_img, (112, 112))
                
                # Tạo embedding
                embedding = self.face_analyzer.get(face_img)
                if embedding:
                    return embedding[0].embedding
                
            return None
            
        except Exception as e:
            logger.error(f"Face embedding extraction failed: {e}")
            return None
    
    def _find_best_match(self, query_embedding: np.ndarray) -> Optional[Dict]:
        """Tìm khuôn mặt tương đồng nhất trong database"""
        try:
            # Lấy tất cả embeddings từ database
            db_embeddings = self.db.query(FaceEmbedding).all()
            
            best_match = None
            best_similarity = 0.0
            
            for db_emb in db_embeddings:
                db_embedding = np.array(db_emb.embedding_vector)
                similarity = self._cosine_similarity(query_embedding, db_embedding)
                
                if similarity > best_similarity:
                    best_similarity = similarity
                    best_match = {
                        'student_id': db_emb.student_id,
                        'similarity': similarity
                    }
            
            return best_match if best_similarity > 0 else None
            
        except Exception as e:
            logger.error(f"Best match search failed: {e}")
            return None
    
    def _cosine_similarity(self, vec1: np.ndarray, vec2: np.ndarray) -> float:
        """Tính cosine similarity giữa 2 vectors"""
        try:
            dot_product = np.dot(vec1, vec2)
            norm1 = np.linalg.norm(vec1)
            norm2 = np.linalg.norm(vec2)
            
            if norm1 == 0 or norm2 == 0:
                return 0.0
            
            return dot_product / (norm1 * norm2)
            
        except Exception as e:
            logger.error(f"Cosine similarity calculation failed: {e}")
            return 0.0
    
    async def _read_image_file(self, image_file) -> Optional[np.ndarray]:
        """Đọc file ảnh và chuyển thành numpy array"""
        try:
            # Đọc file
            contents = await image_file.read()
            nparr = np.frombuffer(contents, np.uint8)
            
            # Decode ảnh
            img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            
            if img is None:
                return None
            
            return img
            
        except Exception as e:
            logger.error(f"Image reading failed: {e}")
            return None
    
    async def _save_image(self, image_file, path: str):
        """Lưu ảnh vào thư mục uploads"""
        try:
            # Tạo thư mục nếu chưa có
            os.makedirs(os.path.dirname(path), exist_ok=True)
            
            # Lưu file
            contents = await image_file.read()
            async with aiofiles.open(path, 'wb') as f:
                await f.write(contents)
                
        except Exception as e:
            logger.error(f"Image saving failed: {e}")
    
    def get_student_embeddings(self, student_id: int) -> List[FaceEmbedding]:
        """Lấy danh sách embeddings của học sinh"""
        try:
            return self.db.query(FaceEmbedding).filter(
                FaceEmbedding.student_id == student_id
            ).all()
        except Exception as e:
            logger.error(f"Failed to get student embeddings: {e}")
            return []
    
    def delete_embedding(self, embedding_id: int) -> bool:
        """Xóa face embedding"""
        try:
            embedding = self.db.query(FaceEmbedding).filter(
                FaceEmbedding.id == embedding_id
            ).first()
            
            if not embedding:
                return False
            
            # Xóa file ảnh nếu có
            if embedding.image_path and os.path.exists(embedding.image_path):
                os.remove(embedding.image_path)
            
            # Xóa record từ database
            self.db.delete(embedding)
            self.db.commit()
            
            return True
            
        except Exception as e:
            self.db.rollback()
            logger.error(f"Failed to delete embedding: {e}")
            return False
    
    async def bulk_recognize_faces(self, images: List, location: str = None, device_id: str = None) -> Dict:
        """Nhận diện nhiều khuôn mặt cùng lúc"""
        try:
            results = {
                "recognized": [],
                "unknown": []
            }
            
            for image in images:
                recognition_result = await self.recognize_face(image, location, device_id)
                
                if recognition_result["student_found"]:
                    results["recognized"].append(recognition_result)
                else:
                    results["unknown"].append(recognition_result)
            
            return results
            
        except Exception as e:
            logger.error(f"Bulk face recognition failed: {e}")
            return {"recognized": [], "unknown": []}
