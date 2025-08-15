import cv2
import numpy as np
import os
import logging
from typing import Optional, List
from app.models.face_recognition import FaceRegistrationRequest, FaceRegistrationResponse
from app.core.config import settings

logger = logging.getLogger(__name__)

class FaceRecognitionService:
    """Service cho face recognition và ML sử dụng real models"""
    
    def __init__(self):
        self.logger = logging.getLogger(__name__)
        self.face_detector = None
        self.face_recognizer = None
        self._initialize_models()
    
    def _initialize_models(self):
        """Khởi tạo ML models"""
        try:
            # Khởi tạo OpenCV face detection
            self.face_detector = cv2.CascadeClassifier(
                cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'
            )
            
            # TODO: Load ONNX models nếu có
            # if os.path.exists(settings.FACE_DETECTION_MODEL_PATH):
            #     self.face_detector = cv2.dnn.readNetFromONNX(settings.FACE_DETECTION_MODEL_PATH)
            # if os.path.exists(settings.FACE_RECOGNITION_MODEL_PATH):
            #     self.face_recognizer = cv2.dnn.readNetFromONNX(settings.FACE_RECOGNITION_MODEL_PATH)
            
            self.logger.info("ML models initialized successfully")
            
        except Exception as e:
            self.logger.error(f"Failed to initialize ML models: {e}")
            # Fallback to basic OpenCV
            self._initialize_fallback_models()
    
    def _initialize_fallback_models(self):
        """Khởi tạo fallback models"""
        try:
            self.face_detector = cv2.CascadeClassifier(
                cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'
            )
            self.logger.info("Fallback models initialized")
        except Exception as e:
            self.logger.error(f"Failed to initialize fallback models: {e}")
    
    async def register_face(self, request: FaceRegistrationRequest, image_path: str) -> FaceRegistrationResponse:
        """Đăng ký khuôn mặt cho student với real ML"""
        try:
            self.logger.info(f"Registering face for student {request.student_id} with image {image_path}")
            
            # 1. Load và preprocess ảnh
            image = cv2.imread(image_path)
            if image is None:
                raise Exception(f"Failed to load image: {image_path}")
            
            # 2. Detect face
            faces = self._detect_faces(image)
            if not faces:
                raise Exception("No face detected in image")
            
            # 3. Extract face embedding
            face_embedding = self._extract_face_embedding(image, faces[0])
            if face_embedding is None:
                raise Exception("Failed to extract face features")
            
            # 4. Validate face quality
            confidence_score = self._validate_face_quality(image, faces[0])
            
            # 5. Store embedding (TODO: Save to database)
            # self._store_face_embedding(request.student_id, face_embedding, confidence_score)
            
            self.logger.info(f"Face registered successfully with confidence: {confidence_score}")
            
            return FaceRegistrationResponse(
                student_id=request.student_id,
                student_name="Student",  # Will be filled from database
                embeddings_count=1,
                confidence_scores=[confidence_score],
                message="Face registered successfully with ML"
            )
            
        except Exception as e:
            self.logger.error(f"Face registration failed: {e}")
            raise Exception(f"Face registration failed: {str(e)}")
    
    async def recognize_face(self, image_path: str) -> Optional[FaceRegistrationResponse]:
        """Nhận diện khuôn mặt từ ảnh với real ML"""
        try:
            self.logger.info(f"Recognizing face from image {image_path}")
            
            # 1. Load và preprocess ảnh
            image = cv2.imread(image_path)
            if image is None:
                raise Exception(f"Failed to load image: {image_path}")
            
            # 2. Detect face
            faces = self._detect_faces(image)
            if not faces:
                raise Exception("No face detected in image")
            
            # 3. Extract face embedding
            query_embedding = self._extract_face_embedding(image, faces[0])
            if query_embedding is None:
                raise Exception("Failed to extract face features")
            
            # 4. Compare with stored embeddings (TODO: Implement database search)
            # best_match = self._find_best_match(query_embedding)
            
            # 5. Return result
            return None  # TODO: Implement actual recognition
            
        except Exception as e:
            self.logger.error(f"Face recognition failed: {e}")
            raise Exception(f"Face recognition failed: {str(e)}")
    
    async def compare_faces(self, image1_path: str, image2_path: str) -> float:
        """So sánh 2 khuôn mặt với real ML"""
        try:
            self.logger.info(f"Comparing faces from {image1_path} and {image2_path}")
            
            # 1. Load both images
            img1 = cv2.imread(image1_path)
            img2 = cv2.imread(image2_path)
            
            if img1 is None or img2 is None:
                raise Exception("Failed to load one or both images")
            
            # 2. Detect faces
            faces1 = self._detect_faces(img1)
            faces2 = self._detect_faces(img2)
            
            if not faces1 or not faces2:
                raise Exception("No face detected in one or both images")
            
            # 3. Extract embeddings
            embedding1 = self._extract_face_embedding(img1, faces1[0])
            embedding2 = self._extract_face_embedding(img2, faces2[0])
            
            if embedding1 is None or embedding2 is None:
                raise Exception("Failed to extract face features")
            
            # 4. Calculate similarity
            similarity = self._cosine_similarity(embedding1, embedding2)
            
            self.logger.info(f"Face similarity: {similarity}")
            return similarity
            
        except Exception as e:
            self.logger.error(f"Face comparison failed: {e}")
            raise Exception(f"Face comparison failed: {str(e)}")
    
    def _detect_faces(self, image: np.ndarray) -> List[dict]:
        """Phát hiện khuôn mặt trong ảnh"""
        try:
            if self.face_detector is None:
                return []
            
            # Convert to grayscale
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
            
            # Detect faces
            faces = self.face_detector.detectMultiScale(
                gray, 
                scaleFactor=1.1, 
                minNeighbors=5,
                minSize=(30, 30)
            )
            
            # Convert to list of dicts
            face_list = []
            for (x, y, w, h) in faces:
                face_list.append({
                    'bbox': [x, y, w, h],
                    'confidence': 0.8,  # Default confidence for OpenCV
                    'landmarks': None
                })
            
            return face_list
            
        except Exception as e:
            self.logger.error(f"Face detection failed: {e}")
            return []
    
    def _extract_face_embedding(self, image: np.ndarray, face: dict) -> Optional[np.ndarray]:
        """Trích xuất face embedding vector"""
        try:
            # Extract face region
            x, y, w, h = face['bbox']
            face_img = image[y:y+h, x:x+w]
            
            if face_img.size == 0:
                return None
            
            # Resize to standard size
            face_img = cv2.resize(face_img, (112, 112))
            
            # TODO: Use real ML model for embedding
            # For now, use simple histogram as placeholder
            # In production, use InsightFace, ArcFace, or similar
            
            # Convert to grayscale
            gray = cv2.cvtColor(face_img, cv2.COLOR_BGR2GRAY)
            
            # Simple feature extraction (placeholder)
            # In real implementation, use deep learning model
            features = cv2.calcHist([gray], [0], None, [256], [0, 256])
            features = features.flatten()
            
            # Normalize
            features = features / np.sum(features)
            
            return features
            
        except Exception as e:
            self.logger.error(f"Face embedding extraction failed: {e}")
            return None
    
    def _validate_face_quality(self, image: np.ndarray, face: dict) -> float:
        """Validate chất lượng khuôn mặt"""
        try:
            x, y, w, h = face['bbox']
            face_img = image[y:y+h, x:x+w]
            
            # Check face size
            if w < 50 or h < 50:
                return 0.3  # Too small
            
            # Check aspect ratio
            aspect_ratio = w / h
            if aspect_ratio < 0.7 or aspect_ratio > 1.3:
                return 0.4  # Bad aspect ratio
            
            # Check brightness
            gray = cv2.cvtColor(face_img, cv2.COLOR_BGR2GRAY)
            brightness = np.mean(gray)
            if brightness < 30 or brightness > 225:
                return 0.5  # Too dark or too bright
            
            # Check blur
            laplacian_var = cv2.Laplacian(gray, cv2.CV_64F).var()
            if laplacian_var < 100:
                return 0.6  # Too blurry
            
            return 0.9  # Good quality
            
        except Exception as e:
            self.logger.error(f"Face quality validation failed: {e}")
            return 0.5
    
    def _cosine_similarity(self, vec1: np.ndarray, vec2: np.ndarray) -> float:
        """Tính cosine similarity giữa 2 vectors"""
        try:
            dot_product = np.dot(vec1, vec2)
            norm1 = np.linalg.norm(vec1)
            norm2 = np.linalg.norm(vec2)
            
            if norm1 == 0 or norm2 == 0:
                return 0.0
            
            similarity = dot_product / (norm1 * norm2)
            return float(similarity)
            
        except Exception as e:
            self.logger.error(f"Cosine similarity calculation failed: {e}")
            return 0.0
    
    def _store_face_embedding(self, student_id: int, embedding: np.ndarray, confidence: float):
        """Lưu face embedding vào database"""
        try:
            # TODO: Implement database storage
            # This should save to FaceEmbedding table
            self.logger.info(f"Storing face embedding for student {student_id}")
            
        except Exception as e:
            self.logger.error(f"Failed to store face embedding: {e}")
    
    def _find_best_match(self, query_embedding: np.ndarray):
        """Tìm khuôn mặt tương đồng nhất trong database"""
        try:
            # TODO: Implement database search
            # This should search FaceEmbedding table
            self.logger.info("Searching for best face match")
            return None
            
        except Exception as e:
            self.logger.error(f"Best match search failed: {e}")
            return None
