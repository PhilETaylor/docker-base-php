# docker build . --tag philetaylor/base-php:latest
# docker push philetaylor/base-php:latest

FROM php:alpine3.13

MAINTAINER Phil Taylor <phil@phil-taylor.com>

RUN apk add  --no-cache --update --virtual  \
    # Base
    buildDeps \
    gcc \
    autoconf \
    build-base

RUN apk update              \
    && apk upgrade          \
    && apk add --no-cache   \
    supervisor              \
    sudo                    \
    composer                \
    git                     \
    openssh                 \
    ca-certificates         \
    curl                    \
    wget                    \
    htop                    \
    postfix                 \
    httpie                  \
    gmp-dev                 \
    libxml2-dev             \
    icu-dev                 \
    libzip-dev              \
    icu                     \
    nano                    \
    zlib-dev                \
    procps                  \
    gnupg \
    && apk upgrade          \
    && wget https://pecl.php.net/get/redis-5.3.4.tgz && pecl install redis-5.3.4.tgz \
    && docker-php-ext-install intl gmp shmop opcache bcmath pdo_mysql pcntl soap \
    && docker-php-ext-configure zip && docker-php-ext-install zip && docker-php-ext-enable zip \
    && apk del buildDeps \
    && cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
    && echo 'memory_limit=1024M' > /usr/local/etc/php/conf.d/memory_limit.ini    \
    && echo 'realpath_cache_size=2048M' > /usr/local/etc/php/conf.d/pathcache.ini         \
    && echo 'realpath_cache_ttl=7200' >> /usr/local/etc/php/conf.d/pathcache.ini          \
    && echo '[opcache]' > /usr/local/etc/php/conf.d/opcache.ini                           \
    && echo 'opcache.memory_consumption = 512M' >> /usr/local/etc/php/conf.d/opcache.ini  \
    && echo 'opcache.max_accelerated_files = 1000000' >> /usr/local/etc/php/conf.d/opcache.ini  \
    && update-ca-certificates \
    && rm -rf /var/cache/apk/*
