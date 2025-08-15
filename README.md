# SchoolSmart - Hệ thống điểm danh thông minh với AI

## Mô tả dự án
SchoolSmart là hệ thống điểm danh tự động sử dụng AI nhận diện khuôn mặt để theo dõi sự hiện diện của học sinh. Hệ thống hoạt động cả online và offline, đảm bảo độ chính xác cao và bảo mật dữ liệu.

## Tính năng chính
- 🎯 Nhận diện khuôn mặt học sinh tự động
- 📱 Hỗ trợ cả Android và iOS (Flutter app)
- 🌐 Hoạt động offline với đồng bộ dữ liệu khi có mạng
- 🔒 Bảo mật dữ liệu với mã hóa
- 📊 Báo cáo và thống kê chi tiết
- ⚡ Xử lý nhanh với AI on-device

## Kiến trúc hệ thống

### Frontend (Flutter)
- **Cross-platform**: Android, iOS, Windows, Web
- **Face Detection**: Camera plugin với AI processing
- **State Management**: Provider pattern
- **Local Storage**: SQLite với sqflite
- **HTTP Client**: Dio cho API calls

### Backend (Python FastAPI)
- **AI Server**: Face recognition với vector storage
- **Database**: PostgreSQL với vector storage
- **API**: RESTful API cho đồng bộ dữ liệu
- **Authentication**: JWT tokens với refresh mechanism

## Cài đặt và chạy

### Yêu cầu hệ thống
- Flutter SDK 3.16+
- Python 3.9+
- Android Studio / Xcode (cho mobile)
- PostgreSQL 15+

### Backend Setup (Windows)

#### Giải pháp 1 – Cài Visual Studio Build Tools (build từ source)

**Bước 1: Cài Visual Studio Build Tools**
1. Tải từ: https://visualstudio.microsoft.com/visual-cpp-build-tools/
2. Trong bước chọn workload:
   - ✅ **Desktop development with C++**
   - ✅ **MSVC v143** (hoặc mới nhất)
   - ✅ **Windows 10/11 SDK**
   - ✅ **CMake tools for Windows**
3. **Restart máy**

**Bước 2: Cài đặt Python packages**
```bash
# Vào thư mục backend
cd backend

# Tạo virtual environment
python -m venv venv

# Kích hoạt virtual environment
venv\Scripts\activate

# Cài cmake và boost trước
pip install cmake boost

# Cài dlib (cần Visual Studio Build Tools)
pip install dlib

# Cài insightface
pip install insightface

# Cài các package còn lại
pip install -r requirements-others.txt
```

**Bước 3: Chạy backend**
```bash
# Chạy với uvicorn
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

#### Giải pháp 2 – Dùng Conda (khuyến nghị cho Windows)

**Bước 1: Cài Miniconda**
```bash
# Tải và cài Miniconda từ: https://docs.conda.io/en/latest/miniconda.html
# Restart terminal sau khi cài

# Tạo environment mới
conda create -n schoolsmart python=3.11
conda activate schoolsmart

# Cài dlib và insightface từ conda (tránh build)
conda install -c conda-forge dlib
conda install -c conda-forge insightface

# Cài các package còn lại
pip install -r requirements-others.txt
```

### Frontend Setup (Flutter)

**Bước 1: Cài Flutter SDK**
```bash
# Tải Flutter từ: https://flutter.dev/docs/get-started/install
# Thêm Flutter vào PATH
flutter doctor
```

**Bước 2: Chạy Flutter app**
```bash
# Vào thư mục Flutter app
cd school_smart_app

# Get dependencies
flutter pub get

# Chạy trên Android
flutter run -d android

# Chạy trên iOS
flutter run -d ios

# Chạy trên Windows
flutter run -d windows
```

### Database Setup

**PostgreSQL:**
```bash
# Tạo database
psql -U postgres
CREATE DATABASE schoolsmart;
\q

# Hoặc dùng Docker
docker run --name postgres-schoolsmart \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=123456 \
  -e POSTGRES_DB=schoolsmart \
  -p 5432:5432 \
  -d postgres:15
```

## API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Đăng ký user mới
- `POST /api/v1/auth/login` - Đăng nhập (JSON format)
- `POST /api/v1/auth/refresh` - Làm mới access token
- `POST /api/v1/auth/logout` - Đăng xuất
- `GET /api/v1/auth/me` - Lấy thông tin user hiện tại

### Students
- `GET /api/v1/students` - Lấy danh sách học sinh
- `POST /api/v1/students` - Thêm học sinh mới
- `PUT /api/v1/students/{id}` - Cập nhật thông tin học sinh
- `DELETE /api/v1/students/{id}` - Xóa học sinh

### Attendance
- `GET /api/v1/attendance` - Lấy lịch sử điểm danh
- `POST /api/v1/attendance` - Ghi điểm danh mới
- `GET /api/v1/attendance/reports` - Báo cáo điểm danh

## Quy trình hoạt động
1. **Thu thập dữ liệu**: Chụp 3-5 ảnh học sinh, tạo embedding vector
2. **Điểm danh**: Nhận diện khuôn mặt real-time, ghi log thời gian
3. **Đồng bộ**: Gửi dữ liệu lên server khi có mạng
4. **Xử lý học sinh mới**: Thêm khuôn mặt mới vào hệ thống
5. **Báo cáo**: Thống kê và xuất báo cáo

## Cấu trúc dự án
```
SchoolSmart/
├── school_smart_app/    # Flutter app (Android, iOS, Windows, Web)
│   ├── lib/            # Dart source code
│   ├── android/        # Android specific code
│   ├── ios/            # iOS specific code
│   ├── windows/        # Windows specific code
│   └── pubspec.yaml    # Flutter dependencies
├── backend/            # Python FastAPI server
│   ├── app/           # Application code
│   ├── requirements.txt          # Full requirements
│   └── requirements-others.txt   # Requirements without dlib/insightface
├── ai-models/          # AI models và scripts
├── docs/              # Tài liệu kỹ thuật
└── scripts/           # Scripts hỗ trợ
```

## Troubleshooting

### Lỗi build Flutter
- **Nguyên nhân**: NDK version mismatch
- **Giải pháp**: Sử dụng NDK version ổn định (25.2.9519653)

### Lỗi build dlib trên Windows
- **Nguyên nhân**: Thiếu Visual Studio Build Tools
- **Giải pháp**: Cài đầy đủ workload C++ hoặc dùng Conda

### Lỗi kết nối database
- **Nguyên nhân**: PostgreSQL chưa chạy hoặc sai thông tin
- **Giải pháp**: Kiểm tra service PostgreSQL hoặc dùng Docker

### Lỗi import modules
- **Nguyên nhân**: Thiếu packages hoặc sai thứ tự cài đặt
- **Giải pháp**: Cài theo đúng thứ tự: cmake → boost → dlib → insightface → requirements-others.txt

### Lỗi login API
- **Nguyên nhân**: OAuth2 form data format
- **Giải pháp**: Backend đã được sửa để chấp nhận JSON format

## Đóng góp
Vui lòng đọc [CONTRIBUTING.md](CONTRIBUTING.md) để biết cách đóng góp vào dự án.

## Giấy phép
MIT License - xem [LICENSE](LICENSE) để biết thêm chi tiết.
