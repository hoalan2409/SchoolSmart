# Student Code Migration Guide

## Tổng quan
Hệ thống đã được cập nhật để sử dụng `student_code` tự động thay vì email để định danh student. Mã student sẽ được tự động generate theo format: `{GRADE}{SEQUENCE_NUMBER}`.

## Thay đổi chính

### 1. Database Model
- Thêm trường `student_code` (VARCHAR(20), unique, not null)
- Email trở thành optional (nullable)
- Loại bỏ unique constraint trên email

### 2. API Changes
- Endpoint mới: `GET /students/code/{student_code}` để tìm student theo mã
- Email không còn bắt buộc khi tạo student
- Student code được tự động generate

### 3. Service Changes
- Logic tự động generate student code theo grade
- Không còn kiểm tra email trùng lặp
- Thêm method `get_student_by_code()`

## Chạy Migration

### Bước 1: Chạy migration script
```bash
cd backend
python run_migration.py
```

### Bước 2: Kiểm tra kết quả
- Kiểm tra bảng `students` có trường `student_code` mới
- Kiểm tra các record cũ đã được populate mã
- Kiểm tra unique constraint trên `student_code`

## Format Student Code

Student code được generate theo format:
- **10A001** - Grade 10A, Student #1
- **10A002** - Grade 10A, Student #2
- **11B001** - Grade 11B, Student #1
- **12C001** - Grade 12C, Student #1

## API Endpoints

### Tạo Student
```http
POST /students/
{
    "full_name": "Nguyễn Văn A",
    "grade": "10A",
    "email": "nguyenvana@example.com"  // Optional
}
```

### Tìm Student theo Code
```http
GET /students/code/10A001
```

### Tìm Student theo ID
```http
GET /students/1
```

## Lưu ý

1. **Migration không thể rollback**: Hãy backup database trước khi chạy
2. **Student code unique**: Mỗi student sẽ có mã duy nhất
3. **Email optional**: Student có thể không có email
4. **Auto-increment**: Mã student tự động tăng theo grade

## Troubleshooting

### Lỗi "student_code already exists"
- Kiểm tra xem có student nào có mã trùng không
- Chạy lại migration để fix

### Lỗi "column student_code does not exist"
- Kiểm tra xem migration đã chạy thành công chưa
- Kiểm tra quyền database user

### Lỗi "unique constraint violation"
- Kiểm tra dữ liệu trong bảng students
- Xóa các record trùng lặp nếu có
