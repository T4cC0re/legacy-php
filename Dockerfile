FROM t4cc0re/squeeze

ARG PHP_EXTRA_CONFIGURE_ARGS
ARG PHP_URL="https://secure.php.net/get/php-5.3.29.tar.xz/from/this/mirror"
ENV PHP_INI_DIR /usr/local/etc/php
ENV buildDeps="libcurl4-openssl-dev libedit-dev libsqlite3-dev libssl-dev libxml2-dev"

# persistent / runtime deps
ENV PHPIZE_DEPS="autoconf file g++ gcc libc-dev make pkg-config re2c"

COPY docker-php-* /usr/local/bin/

RUN apt-get update \
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
	--no-install-recommends \
    && rm -r /var/lib/apt/lists/* \
    && mkdir -p $PHP_INI_DIR/conf.d \
    && mkdir -p /usr/src \
    && cd /usr/src \
    && wget --no-check-certificate -O php.tar.xz "$PHP_URL" \
    && apt-get purge -y --auto-remove $fetchDeps \
    && export CFLAGS="$PHP_CFLAGS" \
        CPPFLAGS="$PHP_CPPFLAGS" \
        LDFLAGS="$PHP_LDFLAGS" \
    && docker-php-source extract \
    && cd /usr/src/php \
    && PATH="/usr/bin:$PATH" ./configure \
        --with-config-file-path="$PHP_INI_DIR" \
        --with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
        --disable-cgi \
        --enable-ftp \
        --enable-mbstring \
        --enable-mysqlnd \
        --with-curl \
        --with-libedit \
        --with-openssl \
        --with-zlib \
        $PHP_EXTRA_CONFIGURE_ARGS \
        && make -j "$(nproc)" \
        && make install \
        && { find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true; } \
        && make clean \
        && docker-php-source delete \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $buildDeps \
    && rm -rf /var/lib/apt/lists/* \

ENTRYPOINT ["docker-php-entrypoint"]
CMD ["php", "-a"]
