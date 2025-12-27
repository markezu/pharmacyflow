# دليل التثبيت والنشر - Deployment Guide
## نظام إدارة الصيدليات (PharmaSys)

---

## 1. المتطلبات الأساسية

### 1.1 للتطوير المحلي
- Docker Desktop (Windows/Mac) أو Docker Engine (Linux)
- Docker Compose v2.0+
- Git

### 1.2 للإنتاج
- خادم Linux (Ubuntu 22.04 LTS موصى به)
- Docker + Docker Compose
- SSL Certificate (Let's Encrypt)
- Domain Name (اختياري)

---

## 2. التثبيت السريع (Quick Start)

### 2.1 استنساخ المشروع
```bash
git clone https://github.com/your-repo/pharmasys.git
cd pharmasys
```

### 2.2 إعداد ملف البيئة
```bash
cp .env.example .env
```

### 2.3 تعديل الإعدادات
```env
# .env
APP_NAME=PharmaSys
APP_ENV=production
APP_DEBUG=false
APP_URL=http://localhost

DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=pharmasys
DB_USERNAME=pharmasys
DB_PASSWORD=your_secure_password

REDIS_HOST=redis
REDIS_PORT=6379

# إعدادات الصيدلية
PHARMACY_NAME="صيدلية الشفاء"
PHARMACY_PHONE="+249123456789"
PHARMACY_ADDRESS="الخرطوم، السودان"
PHARMACY_CURRENCY=SDG
PHARMACY_TAX_RATE=0
```

### 2.4 بدء التشغيل
```bash
# بناء وتشغيل الحاويات
docker-compose up -d --build

# تشغيل الهجرات
docker-compose exec app php artisan migrate --seed

# إنشاء مفتاح التطبيق
docker-compose exec app php artisan key:generate
```

### 2.5 الوصول للنظام
- **التطبيق**: http://localhost
- **API**: http://localhost/api
- **Frontend**: http://localhost:3000

### 2.6 بيانات الدخول الافتراضية
```
البريد: admin@pharmasys.com
كلمة المرور: Admin@123
```

---

## 3. أوامر Docker المفيدة

### 3.1 إدارة الحاويات
```bash
# عرض الحاويات
docker-compose ps

# إيقاف الحاويات
docker-compose stop

# إعادة التشغيل
docker-compose restart

# حذف الحاويات
docker-compose down

# حذف الحاويات والبيانات
docker-compose down -v
```

### 3.2 الصيانة
```bash
# عرض السجلات
docker-compose logs -f app

# دخول shell التطبيق
docker-compose exec app bash

# تشغيل artisan
docker-compose exec app php artisan [command]

# تحديث الاعتماديات
docker-compose exec app composer install

# مسح الكاش
docker-compose exec app php artisan cache:clear
docker-compose exec app php artisan config:clear
```

### 3.3 قاعدة البيانات
```bash
# تشغيل الهجرات
docker-compose exec app php artisan migrate

# إعادة تعيين قاعدة البيانات
docker-compose exec app php artisan migrate:fresh --seed

# النسخ الاحتياطي
docker-compose exec mysql mysqldump -u root -p pharmasys > backup.sql
```

---

## 4. بناء Docker Image للتوزيع

### 4.1 بناء الصورة
```bash
# بناء صورة Backend
docker build -t pharmasys-backend:1.0 ./backend

# بناء صورة Frontend
docker build -t pharmasys-frontend:1.0 ./frontend
```

### 4.2 تصدير الصورة
```bash
# تصدير لملف
docker save pharmasys-backend:1.0 | gzip > pharmasys-backend.tar.gz
docker save pharmasys-frontend:1.0 | gzip > pharmasys-frontend.tar.gz
```

### 4.3 استيراد على جهاز آخر
```bash
# استيراد الصورة
docker load < pharmasys-backend.tar.gz
docker load < pharmasys-frontend.tar.gz
```

### 4.4 رفع لـ Docker Hub
```bash
# تسجيل الدخول
docker login

# وسم الصورة
docker tag pharmasys-backend:1.0 username/pharmasys-backend:1.0

# رفع الصورة
docker push username/pharmasys-backend:1.0
```

---

## 5. النشر على الإنتاج

### 5.1 إعداد الخادم
```bash
# تحديث النظام
sudo apt update && sudo apt upgrade -y

# تثبيت Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# تثبيت Docker Compose
sudo apt install docker-compose-plugin
```

### 5.2 إعداد SSL (Let's Encrypt)
```bash
# تثبيت Certbot
sudo apt install certbot

# الحصول على شهادة
sudo certbot certonly --standalone -d yourdomain.com
```

### 5.3 docker-compose للإنتاج
```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  app:
    image: pharmasys-backend:1.0
    restart: always
    environment:
      - APP_ENV=production
      - APP_DEBUG=false
    
  nginx:
    image: nginx:alpine
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./ssl:/etc/nginx/ssl:ro
      - ./nginx.prod.conf:/etc/nginx/nginx.conf:ro

  mysql:
    image: mysql:8.0
    restart: always
    volumes:
      - mysql-data:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=${DB_PASSWORD}
```

### 5.4 التشغيل
```bash
docker-compose -f docker-compose.prod.yml up -d
```

---

## 6. النسخ الاحتياطي

### 6.1 سكربت النسخ الاحتياطي اليومي
```bash
#!/bin/bash
# backup.sh

DATE=$(date +%Y-%m-%d)
BACKUP_DIR=/backups

# نسخ قاعدة البيانات
docker-compose exec -T mysql mysqldump -u root -p${DB_PASSWORD} pharmasys > ${BACKUP_DIR}/db_${DATE}.sql

# ضغط النسخة
gzip ${BACKUP_DIR}/db_${DATE}.sql

# حذف النسخ القديمة (أكثر من 30 يوم)
find ${BACKUP_DIR} -type f -mtime +30 -delete

echo "Backup completed: ${DATE}"
```

### 6.2 جدولة النسخ التلقائي
```bash
# إضافة لـ crontab
crontab -e

# تشغيل يومياً الساعة 2 صباحاً
0 2 * * * /path/to/backup.sh
```

---

## 7. استكشاف الأخطاء

### 7.1 مشاكل شائعة

| المشكلة | الحل |
|---------|-----|
| فشل الاتصال بقاعدة البيانات | تأكد من أن MySQL container يعمل: `docker-compose ps` |
| 500 Error | راجع السجلات: `docker-compose logs app` |
| صفحة بيضاء | تأكد من صلاحيات storage: `chmod -R 775 storage` |
| بطء الأداء | تحقق من Redis: `docker-compose logs redis` |

### 7.2 إعادة التعيين الكامل
```bash
# إيقاف وحذف كل شيء
docker-compose down -v

# إعادة البناء
docker-compose up -d --build --force-recreate

# إعادة الهجرات
docker-compose exec app php artisan migrate:fresh --seed
```

---

## 8. التحديث

### 8.1 تحديث الكود
```bash
# سحب التحديثات
git pull origin main

# إعادة بناء الحاويات
docker-compose up -d --build

# تشغيل الهجرات الجديدة
docker-compose exec app php artisan migrate

# مسح الكاش
docker-compose exec app php artisan optimize:clear
```

---

*نهاية دليل النشر*
*الإصدار 1.0 - ديسمبر 2025*
