# docker build . --tag registry.myjoomla.com/base-php
# docker push registry.myjoomla.com/base-php

FROM alpine:latest

MAINTAINER Phil Taylor <phil@phil-taylor.com>

# PHP 7.3 Repos
ADD https://repos.php.earth/alpine/phpearth.rsa.pub /etc/apk/keys/phpearth.rsa.pub 
RUN echo "https://repos.php.earth/alpine/v3.8" >> /etc/apk/repositories

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
    nano                    \
    zlib-dev                \
    procps                  \
    gnupg                   \
                            \
    # PHP
    php7.3                  \
    php7.3-dev              \
    php7.3-fpm              \
    php7.3-ftp              \
    php7.3-curl             \
    php7.3-zip              \
    php7.3-mbstring         \
    php7.3-pcntl            \
    php7.3-posix            \
    php7.3-ctype            \
    php7.3-iconv            \
    php7.3-intl             \
    php7.3-pdo_mysql        \
    php7.3-tokenizer        \
    php7.3-dom              \
    # php7.3-redis          \
    php7.3-xml              \
    php7.3-simplexml        \
    php7.3-json             \
    php7.3-sodium           \
    php7.3-opcache          \
    php7.3-shmop            \
    php7.3-fileinfo            \
    php7.3-xmlwriter        \
    php7.3-session          \
    php7.3-common

RUN wget https://github.com/phpredis/phpredis/archive/4.1.1.tar.gz \
    && tar xfz 4.1.1.tar.gz     \
    && rm -r 4.1.1.tar.gz       \
    && cd phpredis-4.1.1        \
    && phpize                   \
    && ./configure              \
    && make                     \
    && make install             \
    && rm -Rf /phpredis-4.1.1 

# PHP-FPM
RUN echo 'memory_limit=1024M' > /etc/php/7.3/conf.d/memory_limit.ini    \
    && echo '[global]' > /etc/php/7.3/php-fpm.d/zz-docker.conf          \
    && echo 'daemonize = no' >> /etc/php/7.3/php-fpm.d/zz-docker.conf   \
    && echo '[www]' >> /etc/php/7.3/php-fpm.d/zz-docker.conf            \
    && echo 'listen=9000' >> /etc/php/7.3/php-fpm.d/zz-docker.conf      \
    && echo 'extension=redis' > /etc/php/7.3/php-fpm.d/redis.ini        \
# PHP CLI
    && echo 'realpath_cache_size=2048M' > /etc/php/7.3/conf.d/pathcache.ini         \
    && echo 'realpath_cache_ttl=7200' >> /etc/php/7.3/conf.d/pathcache.ini          \
    && echo '[opcache]' > /etc/php/7.3/conf.d/opcache.ini                           \
    && echo 'opcache.memory_consumption = 512M' >> /etc/php/7.3/conf.d/opcache.ini  \
    && echo 'opcache.max_accelerated_files = 1000000' >> /etc/php/7.3/conf.d/opcache.ini \
    && echo 'extension=redis' > /etc/php/7.3/conf.d/redis.ini \
# Others
    && update-ca-certificates