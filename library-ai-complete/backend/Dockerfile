FROM php:8.4-apache
RUN apt-get update \
	&& apt-get install -y --no-install-recommends libcurl4-openssl-dev libonig-dev pkg-config \
	&& docker-php-ext-install pdo_mysql curl mbstring \
	&& a2enmod rewrite headers \
	&& rm -rf /var/lib/apt/lists/*
COPY public/ /var/www/html/
COPY src/ /var/www/src/
COPY prompts/ /var/www/prompts/
RUN chown -R www-data:www-data /var/www/html /var/www/src
