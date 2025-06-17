FROM php:8.3-fpm

ARG DATABASE_URL="sqlite:///%kernel.project_dir%/var/data.db"
ENV DATABASE_URL=${DATABASE_URL}

RUN apt-get update && apt-get install -y \
      libsodium-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
      libicu-dev libxslt-dev libxml2-dev zlib1g-dev curl gnupg zip \
      mariadb-client postgresql-client \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install gd intl xsl bcmath pdo_mysql sodium \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer
WORKDIR /var/www/html
COPY --chown=www-data:www-data . .

RUN composer install --no-dev --no-scripts --optimize-autoloader

# ← Replace translation:dump with translation:extract
RUN php bin/console translation:extract --force --no-interaction en \
     --domain=configuration --format=json \
  && php bin/console translation:extract --force --no-interaction en \
     --domain=messages      --format=json

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

EXPOSE 9000
CMD ["php-fpm"]
