# =================================================================
# مرحلة vendor
# =================================================================
FROM composer:2.5 AS vendor

WORKDIR /app
COPY backend/composer.json composer.json
COPY backend/composer.lock composer.lock
RUN composer install --no-dev --no-interaction --no-scripts --prefer-dist

# =================================================================
# مرحلة التشغيل
# =================================================================
FROM php:8.2-cli-alpine

RUN docker-php-ext-install pdo pdo_mysql

WORKDIR /var/www/html

COPY backend/ .
COPY --from=vendor /app/vendor/ ./vendor/

RUN chmod -R 775 storage bootstrap/cache

ENV PORT=8080
EXPOSE 8080

CMD ["sh", "-c", "php -S 0.0.0.0:${PORT} -t public"]
