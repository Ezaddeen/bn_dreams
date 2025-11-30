# =================================================================
# المرحلة الأولى: بناء الواجهة الأمامية (React)
# =================================================================
FROM node:18-alpine AS frontend-builder

WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm install
COPY frontend/ ./
ARG VITE_API_URL
ENV VITE_API_URL=${VITE_API_URL}
RUN npm run build

# =================================================================
# المرحلة الثانية: بناء الواجهة الخلفية (Laravel)
# =================================================================
FROM composer:2 AS backend-vendor

WORKDIR /app/backend
COPY backend/database/ database/
COPY backend/composer.json backend/composer.lock ./
RUN composer install --no-interaction --no-plugins --no-scripts --prefer-dist --ignore-platform-reqs

# =================================================================
# المرحلة النهائية: تجميع كل شيء مع خادم Nginx
# =================================================================
FROM nginx:1.25-alpine

# تثبيت PHP وملحقاته
RUN apk add --no-cache \
    php82 php82-fpm php82-pdo php82-pdo_mysql php82-tokenizer \
    php82-xml php82-ctype php82-curl php82-dom php82-gd \
    php82-intl php82-mbstring php82-openssl php82-phar \
    php82-session php82-zip

# إعداد PHP-FPM
COPY <<EOF /etc/php82/php-fpm.d/www.conf
[www]
user = nginx
group = nginx
listen = /run/php-fpm/www.sock
listen.owner = nginx
listen.group = nginx
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
EOF

# إعداد Nginx
COPY <<EOF /etc/nginx/conf.d/default.conf
server {
    listen 80;
    server_name localhost;
    root /var/www/html/public;
    index index.php;
    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/run/php-fpm/www.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF

WORKDIR /var/www/html

# نسخ كود Laravel
COPY --chown=nginx:nginx backend/ .

# =================================================================
# الحل الأخير: كتابة بيانات الاتصال مباشرة في ملف .env
# تم استخدام الرابط الذي أرسلته
# =================================================================
RUN echo "DB_CONNECTION=mysql" >> .env && \
    echo "DATABASE_URL=mysql://root:ISxxihuBeOZwyafyeOZCZWyMvuUCsvVR@turntable.proxy.rlwy.net:52234/railway" >> .env && \
    echo "APP_KEY=base64:dummykeyforthebuildprocess12345=" >> .env && \
    echo "APP_ENV=production" >> .env
# =================================================================

# نسخ مجلد vendor
COPY --chown=nginx:nginx --from=backend-vendor /app/backend/vendor/ ./vendor/
# نسخ مجلد build الخاص بـ React
COPY --chown=nginx:nginx --from=frontend-builder /app/frontend/dist ./public/

# تعديل الصلاحيات
RUN mkdir -p /run/php-fpm && \
    chown -R nginx:nginx /var/www/html /run/php-fpm && \
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# تشغيل Nginx و PHP-FPM
CMD sh -c "php-fpm82 && nginx -g 'daemon off;'"
