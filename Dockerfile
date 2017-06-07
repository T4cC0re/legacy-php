FROM t4cc0re/squeeze

ARG PHP_EXTRA_CONFIGURE_ARGS="--disable-cgi "
ARG PHP_VERSION=5.3.29
ENV PHP_URL "http://museum.php.net/php5/php-${PHP_VERSION}.tar.gz"
ENV ALT_URL "https://secure.php.net/get/php-${PHP_VERSION}.tar.gz/from/this/mirror"
ENV PHP_INI_DIR /usr/local/etc/php

# temp / build deps
ENV buildDeps "\
    bison \
    bzip2 \
    flex \
    libbz2-dev \
    libcurl4-openssl-dev \
    libedit-dev \
    libjpeg8-dev \
    libmhash-dev \
    libmysqlclient-dev \
    libpng12-dev \
    libreadline5-dev \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
"

# persistent / runtime deps
ENV PHPIZE_DEPS "\
    autoconf \
    file \
    g++ \
    gcc \
    libc-dev \
    libedit2 \
    libjpeg8 \
    libmhash2 \
    libmysqlclient16 \
    libpng12-0 \
    libxslt1.1 \
    make \
    pkg-config \
    re2c \
"

ENV PATH "/legacy-php/bin:/legacy-php/sbin:/usr/bin:$PATH"

COPY docker-php-entrypoint docker-php-ext-configure docker-php-ext-enable docker-php-ext-install docker-php-source /legacy-php/bin/

RUN set -x \
    && echo "Building: $PHP_VERSION" \
    && chmod +x /legacy-php/bin/* \
    && apt-get update \
    && apt-get install -y \
        $PHPIZE_DEPS \
        $buildDeps \
        ca-certificates \
        curl \
        libedit2 \
        libsqlite3-0 \
        libxml2 \
        wget \
        xz-utils \
        --no-install-recommends >/dev/null \
    && rm -r /var/lib/apt/lists/* \
    && mkdir -p $PHP_INI_DIR/conf.d \
    && mkdir -p /usr/src \
    && cd /usr/src \
    && (wget -nv --no-check-certificate -O php.tar.gz "$PHP_URL" || wget --no-check-certificate -nv -O php.tar.gz "$ALT_URL") \
    && export CFLAGS="$PHP_CFLAGS" \
        CPPFLAGS="$PHP_CPPFLAGS" \
        LDFLAGS="$PHP_LDFLAGS" \
    && mkdir -p /usr/src/php \
    && docker-php-source extract \
    && cd /usr/src/php \
    && LD_LIBRARY_PATH=/usr/local/lib ./configure \
        --prefix=/legacy-php \
        --with-config-file-path="$PHP_INI_DIR" \
        --with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
        \
#        --disable-cli \
        --enable-bcmath \
        --with-curl \
        --enable-exif \
#        --enable-fastcgi \
        --enable-ftp \
        --enable-gd-native-ttf \
        --enable-mbstring \
        --enable-mysqlnd \
        --enable-pcntl \
        --enable-shmop \
        --enable-soap \
        --enable-sockets \
        --enable-sqlite-utf8 \
        --with-curl \
        --with-bz2 \
        --with-gd \
        --with-imap-ssl \
        --with-jpeg-dir \
        --with-libedit \
        --with-mhash \
        --with-mysql \
        --with-mysqli \
        --with-openssl \
        --with-pdo-mysql \
        --with-pdo-sqlite \
        --with-pear \
        --with-png-dir \
        --with-ttf \
        --with-xmlrpc \
        --with-xsl \
        --with-zlib \
        $PHP_EXTRA_CONFIGURE_ARGS >/dev/null \
        && make -j "$(nproc)" >/dev/null \
        && make install \
        && { find /legacy-php -type f -executable -exec strip --strip-all '{}' + || true; } \
        && make clean \
        && docker-php-source delete \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $buildDeps \
    && rm -rf -- /var/lib/apt/lists/*
