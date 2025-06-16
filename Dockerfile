FROM php:8.3-fpm

# 1) Install system deps + PHP extensions (including sodium)
RUN apt-get update && apt-get install -y \
      libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
      libicu-dev libxslt-dev libxml2-dev zlib1g-dev \
      libsodium-dev curl gnupg zip mariadb-client postgresql-client \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install \
       gd intl xsl bcmath pdo_mysql sodium \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2) Bring in Composer
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

WORKDIR /var/www/html

# 3) Copy your app code
COPY --chown=www-data:www-data . .

# 4) Install PHP deps **before** running any Symfony commands
RUN composer install --no-dev --no-scripts --optimize-autoloader

# 5) Now you can dump your translations
RUN php bin/console translation:dump --format=json --output-dir=var/translations

# 6) Install Node/Yarn & build assets
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
 && curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/yarn.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian stable main" \
    > /etc/apt/sources.list.d/yarn.list \
 && apt-get update \
 && apt-get install -y nodejs yarn \
 && yarn install --network-timeout 600000 \
 && yarn build \
 && yarn cache clean \
 && rm -rf /var/lib/apt/lists/*

# 7) Expose & run PHP-FPM
EXPOSE 9000
CMD ["php-fpm"]
