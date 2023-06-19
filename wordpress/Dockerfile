ARG BUILD_FROM
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Setup base
# hadolint ignore=DL3003
RUN \
    apk add --no-cache \
        mariadb-client=10.11.4-r0 \
        nginx=1.24.0-r6 \
        php81-curl=8.1.20-r0 \
        php81-fpm=8.1.20-r0 \
        php81-gd=8.1.20-r0 \
        php81-iconv=8.1.20-r0 \
        php81-mbstring=8.1.20-r0 \
        php81-mysqli=8.1.20-r0 \
        php81-opcache=8.1.20-r0 \
        php81-openssl=8.1.20-r0 \
        php81-session=8.1.20-r0 \
        php81-xml=8.1.20-r0 \
        php81-zip=8.1.20-r0 \
        php81=8.1.20-r0 \
    \
    && mkdir /var/www/wordpress \
    && curl -L -s \
        "https://wordpress.org/latest.tar.gz" \
        | tar zxvf - --strip 1 -C /var/www/wordpress \
    #\
    # && sed -i "s@'configFile' =>.*@'configFile' => '/etc/phpmyadmin/config.inc.php',@" \
    #    /var/www/phpmyadmin/libraries/vendor_config.php \
    && mv /var/www/wordpress/wp-config{-sample,}.php \
    && sed -i 's/database_name_here/(bashio::config "db_name")/g' /var/www/wordpress/wp-config.php \
    && sed -i 's/username_here/(bashio::config "db_username")/g' /var/www/wordpress/wp-config.php \
    && sed -i 's/password_here/(bashio::config "db_password")/g' /var/www/wordpress/wp-config.php \
    && sed -i 's/localhost/core_mariadb:3306/g' /var/www/wordpress/wp-config.php


# Copy root filesystem
COPY rootfs /

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Wanno Drijfhout <github.com@wanno.eu>" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Wanno's Home Assistant goodies" \
    org.opencontainers.image.authors="Wanno Drijfhout <github.com@wanno.eu>" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://github.com/wanno-drijfhout/home-assistant-goodies" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/master/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}