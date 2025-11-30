# =================================================================
# المرحلة الأولى: بناء الاعتماديات
# =================================================================
FROM composer:2.5 AS vendor

WORKDIR /app
COPY backend/database/ database/
COPY backend/composer.json composer.json
COPY backend/composer.lock composer.lock
RUN composer install --no-dev --no-interaction --no-plugins --no-scripts --prefer-dist

# =================================================================
# المرحلة النهائية: بناء صورة التشغيل
# =================================================================
FROM nginx:1.25-alpine

# تثبيت PHP وملحقاته الأساسية
RUN apk add --no-cache php82-fpm php82-pdo php82-pdo_mysql php82-xml php82-dom php82-mbstring php82-tokenizer php82-ctype php82-curl php82-session

# إعداد Nginx
COPY <<EOF /etc/nginx/conf.d/default.conf
server {
    listen 80;
    server_name localhost;
    root /var/www/html/public;
    index index.php;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param PATH_INFO \$fastcgi_path_info;
    }
}
EOF

# إعداد PHP-FPM
COPY <<EOF /etc/php82/php-fpm.d/www.conf
[www]
user = nginx
group = nginx
listen = 127.0.0.1:9000
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
EOF

WORKDIR /var/www/html

# نسخ كود Laravel
COPY --chown=nginx:nginx backend/ .
# نسخ مجلد vendor الجاهز
COPY --chown=nginx:nginx --from=vendor /app/vendor/ ./vendor/

# تعديل الصلاحيات
RUN chown -R nginx:nginx /var/www/html && \
    chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# تشغيل الخدمات
CMD sh -c "php-fpm82 && nginx -g 'daemon off;'"
