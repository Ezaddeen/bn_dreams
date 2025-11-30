# =================================================================
# المرحلة الأولى: بناء الاعتماديات (vendor)
# =================================================================
FROM composer:2.5 AS vendor

WORKDIR /app
COPY backend/composer.json composer.json
COPY backend/composer.lock composer.lock
RUN composer install --no-dev --no-interaction --no-scripts --prefer-dist

# =================================================================
# المرحلة النهائية: تشغيل Laravel على Railway
# =================================================================
FROM php:8.2-cli-alpine

# تثبيت ملحقات Laravel
RUN docker-php-ext-install pdo pdo_mysql

WORKDIR /var/www/html

# نسخ المشروع
COPY backend/ .
COPY --from=vendor /app/vendor/ ./vendor/

# الصلاحيات
RUN chmod -R 775 storage bootstrap/cache

# المنفذ ل Railway
ENV PORT=8080
EXPOSE 8080

# تشغيل سيرفر PHP (بالطريقة الصحيحة التي تسمح بتفسير المتغير)
CMD sh -c "php -S 0.0.0.0:${PORT} -t public"
