FROM php:8.3-apache

# 1. Install ekstensi sistem & driver PostgreSQL
RUN apt-get update && apt-get install -y libpq-dev libzip-dev libicu-dev zip unzip git curl
RUN docker-php-ext-install pdo pdo_pgsql zip intl

# 2. Konfigurasi Apache
RUN a2enmod rewrite
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf

# 3. Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 4. Pindahkan kode proyek
WORKDIR /var/www/html
COPY . .

# 5. Install dependensi Backend SAJA (Beban berat NPM dihapus)
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --optimize-autoloader --no-interaction

# 6. Berikan izin akses folder
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache