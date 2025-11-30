# =================================================================
# المرحلة الأولى: بناء الاعتماديات (vendor)
# =================================================================
FROM composer:2.5 AS vendor

WORKDIR /app
COPY backend/composer.json composer.json
COPY backend/composer.lock composer.lock
# --no-scripts يمنع artisan من العمل قبل وجود .env
RUN composer install --no-dev --no-interaction --no-scripts --prefer-dist

# =================================================================
# المرحلة النهائية: بناء صورة التشغيل
# =================================================================
FROM php:8.2-cli-alpine

# تثبيت الإضافات الأساسية التي يحتاجها Laravel
RUN docker-php-ext-install pdo pdo_mysql

WORKDIR /var/www/html

# نسخ كود Laravel من مجلد backend
COPY backend/ .
# نسخ مجلد vendor الجاهز من المرحلة الأولى
COPY --from=vendor /app/vendor/ ./vendor/

# تعديل الصلاحيات (مهم جداً لـ Laravel)
RUN chmod -R 775 storage bootstrap/cache

# هذا هو الأمر الحاسم:
# تشغيل خادم PHP المدمج على المنفذ الذي يحدده Railway
# واستخدام مجلد public كـ root.
CMD php -S 0.0.0.0:${PORT} -t public
