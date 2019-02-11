# docker build . --tag registry.myjoomla.com/base-php
# docker push registry.myjoomla.com/base-php

FROM php:7.3.2-cli-alpine3.9

MAINTAINER Phil Taylor <phil@phil-taylor.com>

RUN apk  add  --no-cache --update --virtual  \
    # Base
    buildDeps \
    gcc \
    autoconf \
    build-base 
 

RUN apk update              \
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
    gnupg                   

RUN docker-php-ext-install intl
RUN docker-php-ext-install gmp 
RUN docker-php-ext-install shmop 
RUN docker-php-ext-install opcache
RUN docker-php-ext-install bcmath 
RUN docker-php-ext-install pdo_mysql 
RUN docker-php-ext-install pcntl  
RUN docker-php-ext-install soap
RUN docker-php-ext-configure zip --with-libzip 
RUN docker-php-ext-install zip  
RUN docker-php-ext-enable zip  
RUN pecl install redis-4.2.0 
RUN apk del buildDeps

RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini 

# PHP-FPM
RUN echo 'memory_limit=1024M' > /usr/local/etc/php/conf.d/memory_limit.ini    \
# PHP CLI
    && echo 'realpath_cache_size=2048M' > /usr/local/etc/php/conf.d/pathcache.ini         \
    && echo 'realpath_cache_ttl=7200' >> /usr/local/etc/php/conf.d/pathcache.ini          \
    && echo '[opcache]' > /usr/local/etc/php/conf.d/opcache.ini                           \
    && echo 'opcache.memory_consumption = 512M' >> /usr/local/etc/php/conf.d/opcache.ini  \
    && echo 'opcache.max_accelerated_files = 1000000' >> /usr/local/etc/php/conf.d/opcache.ini  \
# Others
    && update-ca-certificates