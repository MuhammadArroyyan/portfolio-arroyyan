FROM php:8.2-apache

# 1. Install ekstensi sistem & driver PostgreSQL
RUN apt-get update && apt-get install -y libpq-dev libzip-dev libicu-dev zip unzip git curl
RUN docker-php-ext-install pdo pdo_pgsql zip intl

# 2. Install Node.js (Untuk memproses TailwindCSS)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# 3. Konfigurasi Apache (Arahkan server ke folder /public Laravel)
RUN a2enmod rewrite
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf

# 4. Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 5. Pindahkan seluruh kode proyek Anda ke dalam server
WORKDIR /var/www/html
COPY . .

# 6. Install dependensi & Build frontend
RUN composer install --no-dev --optimize-autoloader
RUN npm install
RUN npm run build

# 7. Berikan izin akses folder agar aplikasi tidak error
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache