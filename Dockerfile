# =================================================================
# المرحلة الأولى: بناء الواجهة الأمامية (React)
# =================================================================
FROM node:18-alpine AS frontend-builder

WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm install
COPY frontend/ ./
# مهم: يجب أن نخبر React بعنوان الـ API في وقت البناء
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
# سنقوم بتثبيت كل شيء (بما في ذلك حزم التطوير للسماح بالـ Seeding)
RUN composer install --no-interaction --no-plugins --no-scripts --prefer-dist --ignore-platform-reqs


# =================================================================
# المرحلة النهائية: تجميع كل شيء مع خادم Nginx
# =================================================================
FROM nginx:1.25-alpine

# تثبيت PHP وملحقاته
RUN RUN apk add --no-cache \
    php82 php82-fpm php82-pdo php82-pdo_mysql php82-tokenizer \
    php82-xml php82-ctype php82-curl php82-dom php82-gd \
    php82-intl php82-mbstring php82-openssl php82-phar \
    php82-session php82-zip

# إعداد Nginx عن طريق دمج الملف مباشرة هنا
COPY <<EOF /etc/nginx/conf.d/default.conf
server {
    listen 80;
    server_name localhost;
    root /var/www/html/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    # هذا الجزء مهم: يوجه كل الطلبات التي لا تطابق ملفاً إلى React
    location / {
        try_files \$uri \$uri/ /index.html;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    # هذا الجزء يشغل Laravel
    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
EOF

WORKDIR /var/www/html

# نسخ كود Laravel من المشروع المحلي
COPY --chown=nginx:nginx backend/ .

# نسخ مجلد vendor الجاهز من مرحلة بناء الـ backend
COPY --chown=nginx:nginx --from=backend-vendor /app/backend/vendor/ ./vendor/

# نسخ مجلد build الجاهز من مرحلة بناء الـ frontend إلى مجلد public الخاص بـ Laravel
# ملاحظة: تأكد من أن مجلد البناء في مشروع React هو 'dist'. إذا كان 'build'، غير الكلمة أدناه.
COPY --chown=nginx:nginx --from=frontend-builder /app/frontend/dist ./public/

# تعديل الصلاحيات
RUN chown -R nginx:nginx /var/www/html/storage /var/www/html/bootstrap/cache
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# تشغيل Nginx و PHP-FPM
CMD sh -c "php-fpm82 && nginx -g 'daemon off;'"
