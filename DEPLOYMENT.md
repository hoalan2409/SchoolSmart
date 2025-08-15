# Hướng dẫn triển khai SchoolSmart

## Yêu cầu hệ thống

### Backend Server
- **OS**: Ubuntu 20.04+ hoặc CentOS 8+
- **CPU**: 4 cores trở lên (khuyến nghị 8 cores)
- **RAM**: 8GB trở lên (khuyến nghị 16GB)
- **Storage**: 100GB trở lên (SSD khuyến nghị)
- **GPU**: NVIDIA GPU với CUDA support (tùy chọn, cho AI processing)

### Mobile Device
- **Android**: 8.0+ (API level 26+)
- **iOS**: 12.0+
- **RAM**: 3GB trở lên
- **Camera**: Camera trước và sau chất lượng tốt

## Cài đặt và triển khai

### 1. Chuẩn bị môi trường

```bash
# Cập nhật hệ thống
sudo apt update && sudo apt upgrade -y

# Cài đặt Docker và Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Cài đặt Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Cài đặt Node.js và npm
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Cài đặt Python 3.9+
sudo apt install python3.9 python3.9-pip python3.9-venv
```

### 2. Clone và cài đặt dự án

```bash
# Clone repository
git clone https://github.com/your-username/schoolsmart.git
cd schoolsmart

# Tạo file môi trường
cp .env.example .env
# Chỉnh sửa .env với thông tin thực tế
```

### 3. Cấu hình database

```bash
# Tạo database PostgreSQL
sudo -u postgres psql
CREATE DATABASE schoolsmart;
CREATE USER schoolsmart_user WITH PASSWORD 'your_secure_password';
GRANT ALL PRIVILEGES ON DATABASE schoolsmart TO schoolsmart_user;
\q

# Hoặc sử dụng Docker
docker-compose up postgres -d
```

### 4. Triển khai với Docker

```bash
# Build và khởi chạy tất cả services
docker-compose up -d

# Kiểm tra trạng thái
docker-compose ps

# Xem logs
docker-compose logs -f backend
```

### 5. Cài đặt AI Models

```bash
# Tạo thư mục models
mkdir -p models

# Download pre-trained models
cd models

# BlazeFace (Face Detection)
wget https://storage.googleapis.com/mediapipe-models/face_detection/blaze_face_short_range/float16/1/blaze_face_short_range.tflite

# MobileFaceNet (Face Recognition)
wget https://github.com/your-repo/mobilefacenet/raw/main/mobilefacenet.tflite

# ArcFace (Server-side recognition)
wget https://github.com/your-repo/arcface/raw/main/arcface.onnx
```

### 6. Cấu hình Nginx

```bash
# Tạo SSL certificate (Let's Encrypt)
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com

# Cấu hình Nginx
sudo nano /etc/nginx/sites-available/schoolsmart
```

Nginx configuration:
```nginx
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com;
    
    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
    
    # API Backend
    location /api/ {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Static files
    location /uploads/ {
        alias /var/www/uploads/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
    
    # Frontend (nếu có web version)
    location / {
        root /var/www/schoolsmart;
        try_files $uri $uri/ /index.html;
    }
}
```

### 7. Cấu hình React Native App

```bash
cd frontend

# Cài đặt dependencies
npm install

# Cấu hình API endpoint
# Chỉnh sửa src/config/api.js
```

### 8. Khởi chạy ứng dụng

```bash
# Backend
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000

# Frontend (Android)
cd frontend
npx react-native run-android

# Frontend (iOS)
cd frontend
npx react-native run-ios
```

## Cấu hình bảo mật

### 1. Firewall

```bash
# Cấu hình UFW
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 8000/tcp
```

### 2. SSL/TLS

```bash
# Tự động gia hạn Let's Encrypt
sudo crontab -e
# Thêm dòng:
0 12 * * * /usr/bin/certbot renew --quiet
```

### 3. Database Security

```bash
# Tạo user riêng cho ứng dụng
CREATE USER schoolsmart_app WITH PASSWORD 'strong_password';
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO schoolsmart_app;
```

## Monitoring và Logging

### 1. Log Rotation

```bash
# Cấu hình logrotate
sudo nano /etc/logrotate.d/schoolsmart

/var/log/schoolsmart/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 644 www-data www-data
}
```

### 2. Health Checks

```bash
# Tạo script health check
cat > /usr/local/bin/schoolsmart-health << 'EOF'
#!/bin/bash
curl -f http://localhost:8000/health || exit 1
curl -f http://localhost:5432 || exit 1
curl -f http://localhost:6379 || exit 1
EOF

chmod +x /usr/local/bin/schoolsmart-health

# Thêm vào crontab
*/5 * * * * /usr/local/bin/schoolsmart-health
```

## Backup và Recovery

### 1. Database Backup

```bash
# Tạo script backup
cat > /usr/local/bin/schoolsmart-backup << 'EOF'
#!/bin/bash
BACKUP_DIR="/backup/schoolsmart"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR

# Backup PostgreSQL
docker exec schoolsmart_postgres pg_dump -U schoolsmart_user schoolsmart > $BACKUP_DIR/db_$DATE.sql

# Backup uploads
tar -czf $BACKUP_DIR/uploads_$DATE.tar.gz uploads/

# Cleanup old backups (keep 30 days)
find $BACKUP_DIR -name "*.sql" -mtime +30 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete
EOF

chmod +x /usr/local/bin/schoolsmart-backup

# Thêm vào crontab (backup hàng ngày lúc 2 AM)
0 2 * * * /usr/local/bin/schoolsmart-backup
```

### 2. Recovery

```bash
# Restore database
docker exec -i schoolsmart_postgres psql -U schoolsmart_user schoolsmart < backup_file.sql

# Restore uploads
tar -xzf backup_file.tar.gz
```

## Troubleshooting

### 1. Kiểm tra logs

```bash
# Backend logs
docker-compose logs backend

# Database logs
docker-compose logs postgres

# Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### 2. Kiểm tra performance

```bash
# CPU và Memory usage
htop

# Disk usage
df -h

# Network connections
netstat -tulpn
```

### 3. Restart services

```bash
# Restart tất cả services
docker-compose restart

# Restart service cụ thể
docker-compose restart backend
```

## Scaling

### 1. Horizontal Scaling

```bash
# Scale backend services
docker-compose up -d --scale backend=3

# Load balancer với Nginx
# Thêm upstream trong nginx.conf
```

### 2. Database Scaling

```bash
# Read replicas
# Cấu hình PostgreSQL streaming replication
# Sử dụng pgpool-II cho connection pooling
```

## Maintenance

### 1. Cập nhật hệ thống

```bash
# Pull latest code
git pull origin main

# Rebuild containers
docker-compose build --no-cache
docker-compose up -d

# Database migrations
docker-compose exec backend alembic upgrade head
```

### 2. Security Updates

```bash
# Cập nhật packages
sudo apt update && sudo apt upgrade -y

# Cập nhật Docker images
docker-compose pull
docker-compose up -d
```

## Support

- **Documentation**: [Wiki](https://github.com/your-username/schoolsmart/wiki)
- **Issues**: [GitHub Issues](https://github.com/your-username/schoolsmart/issues)
- **Email**: support@schoolsmart.com
- **Phone**: +84-xxx-xxx-xxx
