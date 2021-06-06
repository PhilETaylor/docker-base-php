# docker build . --tag philetaylor/base-php
# docker push philetaylor/base-php
# https://github.com/docker-library/php/tree/master/7.4/alpine3.12/cli

FROM alpine:latest

# dependencies required for running "phpize"
# these get automatically installed and removed by "docker-php-ext-*" (unless they're already installed)
ENV PHPIZE_DEPS \
		autoconf \
		dpkg-dev dpkg \
		file \
		g++ \
		gcc \
		libc-dev \
		oniguruma-dev \
		make \
		pkgconf \
		re2c bison curl-dev
ENV PHP_INI_DIR /usr/local/etc/php
# Apply stack smash protection to functions using local buffers and alloca()
# Make PHP's main executable position-independent (improves ASLR security mechanism, and has no performance impact on x86_64)
# Enable optimization (-O2)
# Enable linker optimization (this sorts the hash buckets to improve cache locality, and is non-default)
# https://github.com/docker-library/php/issues/272
# -D_LARGEFILE_SOURCE and -D_FILE_OFFSET_BITS=64 (https://www.php.net/manual/en/intro.filesystem.php)
ENV PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
ENV PHP_CPPFLAGS="$PHP_CFLAGS"
ENV PHP_LDFLAGS="-Wl,-O1 -pie"

COPY docker-php-* /usr/local/bin/

# persistent / runtime deps
RUN apk add --no-cache \
		ca-certificates \
		curl \
		git \
		tar \
		xz \
# https://github.com/docker-library/php/issues/494
		openssl;\
		set -eux; \
	addgroup -g 82 -S www-data; \
	adduser -u 82 -D -S -G www-data www-data;\
	set -eux; \
	mkdir -p "$PHP_INI_DIR/conf.d"; \
# allow running as an arbitrary user (https://github.com/docker-library/php/issues/743)
	[ ! -d /var/www/html ]; \
	mkdir -p /var/www/html; \
	chown www-data:www-data /var/www/html; \
	chmod 777 /var/www/html; \
	mkdir -p /usr/src/php; \
    git clone https://github.com/php/php-src.git /usr/src/php; \
    cd /usr/src/php; \
    git checkout PHP-8.0.7 ; \
    rm -Rf /usr/src/php/.git; \
    set -eux; \
	apk add --no-cache --virtual .build-deps \
		$PHPIZE_DEPS \
		argon2-dev \
		coreutils \
		curl-dev \
		libedit-dev \
		libsodium-dev \
		libxml2-dev \
		linux-headers \
		oniguruma-dev \
		openssl-dev \
		sqlite-dev \
	; \
	\
	export CFLAGS="$PHP_CFLAGS" \
		CPPFLAGS="$PHP_CPPFLAGS" \
		LDFLAGS="$PHP_LDFLAGS" \
	; \
	docker-php-source extract; \
	cd /usr/src/php; \
	gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
	./buildconf; \
	./configure \
		--build="$gnuArch" \
		--with-config-file-path="$PHP_INI_DIR" \
		--with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
		\
# make sure invalid --configure-flags are fatal errors instead of just warnings
		--enable-option-checking=fatal \
		\
# https://github.com/docker-library/php/issues/439
		--with-mhash \
		\
# --enable-ftp is included here because ftp_ssl_connect() needs ftp to be compiled statically (see https://github.com/docker-library/php/issues/236)
		--enable-ftp \
# --enable-mbstring is included here because otherwise there's no way to get pecl to use it properly (see https://github.com/docker-library/php/issues/195)
		--enable-mbstring \
# --enable-mysqlnd is included here because it's harder to compile after the fact than extensions are (since it's a plugin for several extensions, not an extension in itself)
		--enable-mysqlnd \
# https://wiki.php.net/rfc/argon2_password_hash (7.2+)
		--with-password-argon2 \
# https://wiki.php.net/rfc/libsodium
		--with-sodium=shared \
# always build against system sqlite3 (https://github.com/php/php-src/commit/6083a387a81dbbd66d6316a3a12a63f06d5f7109)
		--with-pdo-sqlite=/usr \
		--with-sqlite3=/usr \
		\
		--with-curl \
		--with-libedit \
		--with-openssl \
		--with-zlib \
		\
# in PHP 7.4+, the pecl/pear installers are officially deprecated (requiring an explicit "--with-pear")
# ... and are removed in PHP 8+; see also https://github.com/docker-library/php/pull/847#issuecomment-505638229
		--with-pear \
		\
# bundled pcre does not support JIT on s390x
# https://manpages.debian.org/stretch/libpcre3-dev/pcrejit.3.en.html#AVAILABILITY_OF_JIT_SUPPORT
		$(test "$gnuArch" = 's390x-linux-musl' && echo '--without-pcre-jit') \
		\
		${PHP_EXTRA_CONFIGURE_ARGS:-} \
	; \
	make -j "$(nproc)"; \
	find -type f -name '*.a' -delete; \
	make install; \
	find /usr/local/bin /usr/local/sbin -type f -perm +0111 -exec strip --strip-all '{}' + || true; \
	make clean; \
	\
# https://github.com/docker-library/php/issues/692 (copy default example "php.ini" files somewhere easily discoverable)
	cp -v php.ini-* "$PHP_INI_DIR/"; \
	\
	cd /; \
	docker-php-source delete; \
	\
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --no-cache $runDeps; \
	\
	apk del --no-network .build-deps; \
	\
# update pecl channel definitions https://github.com/docker-library/php/issues/443
	pecl update-channels; \
	rm -rf /tmp/pear ~/.pearrc; \
	\
# smoke test
	php --version; \
    docker-php-ext-enable sodium; \
    apk  add  --no-cache --update --virtual  \
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
        postfix                 \
        gmp-dev                 \
        libxml2-dev             \
        icu-dev                 \
        libzip-dev              \
        icu                     \
        nano                    \
        zlib-dev                \
        procps                  \
        gnupg                   \
    && wget https://pecl.php.net/get/redis-5.3.3.tgz && pecl install redis-5.3.3.tgz && docker-php-ext-enable redis \
    && docker-php-ext-configure zip \
    && docker-php-ext-install intl gmp shmop opcache bcmath pdo_mysql pcntl soap zip \
    && docker-php-source delete \
    && apk del --no-cache build-base buildDeps \
    && cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini  \
    && echo 'memory_limit=1024M' > /usr/local/etc/php/conf.d/memory_limit.ini    \
    && echo 'realpath_cache_size=2048M' > /usr/local/etc/php/conf.d/pathcache.ini         \
    && echo 'realpath_cache_ttl=7200' >> /usr/local/etc/php/conf.d/pathcache.ini          \
    && echo '[opcache]' > /usr/local/etc/php/conf.d/opcache.ini                           \
    && echo 'opcache.memory_consumption = 512M' >> /usr/local/etc/php/conf.d/opcache.ini  \
    && echo 'opcache.max_accelerated_files = 1000000' >> /usr/local/etc/php/conf.d/opcache.ini  \
    && echo "default_socket_timeout=1200" >> /usr/local/etc/php/php.ini \
    && update-ca-certificates \
    && rm -Rf /tmp/pear             \
    && rm -rf /var/cache/apk/*                                                          \
    && rm -rf /var/cache/fontcache/*                                                    \
    && rm -rf /usr/src/php.tar.xz                                                       \
    && rm -Rf /usr/local/bin/phpdbg \
    && rm -Rf /usr/src/php

ENTRYPOINT ["docker-php-entrypoint"]
