# docker build . --tag registry.myjoomla.com/base-php
# docker push registry.myjoomla.com/base-php

FROM php:7.3.6-cli-alpine3.9

MAINTAINER Phil Taylor <phil@phil-taylor.com>

RUN apk  add  --no-cache --update --virtual  \
    # Base
    buildDeps \
    gcc \
    autoconf \
    build-base  \
 && apk update              \
    && apk upgrade          \
    && apk add --no-cache   \
    # Base
    supervisor              \
    sudo                    \
    composer                \
    git                     \
    openssh                 \
    ca-certificates         \
    curl                    \
    wget                    \
    htop                    \
    httpie                  \
    gmp-dev\
    libxml2-dev\
    icu-dev \
    libzip-dev   \
    icu \
    nano                    \
    zlib-dev                \
    procps                  \
    gnupg              \
&& pecl install redis-4.3.0    \                                                    
&& docker-php-ext-configure zip --with-libzip \
&& docker-php-ext-install intl gmp shmop opcache bcmath pdo_mysql pcntl soap zip\
&& docker-php-source delete \
&& apk del --no-cache build-base buildDeps \
&& cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini  \
&& echo 'memory_limit=1024M' > /usr/local/etc/php/conf.d/memory_limit.ini    \
&& echo 'realpath_cache_size=2048M' > /usr/local/etc/php/conf.d/pathcache.ini         \
&& echo 'realpath_cache_ttl=7200' >> /usr/local/etc/php/conf.d/pathcache.ini          \
&& echo '[opcache]' > /usr/local/etc/php/conf.d/opcache.ini                           \
&& echo 'opcache.memory_consumption = 512M' >> /usr/local/etc/php/conf.d/opcache.ini  \
&& echo 'opcache.max_accelerated_files = 1000000' >> /usr/local/etc/php/conf.d/opcache.ini  \
&& echo 'extension=redis' > /usr/local/etc/php/conf.d/redis.ini \
&& echo "default_socket_timeout=1200" >> /usr/local/etc/php/php.ini \
&& update-ca-certificates \
&& rm -Rf /tmp/pear             \
&& rm -rf /var/cache/apk/*                                                          \
&& rm -rf /var/cache/fontcache/*                                                    \
&& rm -rf /usr/src/php.tar.xz                                                       \
&& rm -Rf /usr/local/bin/phpdbg 
