FROM php:7.2-fpm-alpine
MAINTAINER FluxoTI <lucas.gois@fluxoti.com>

COPY . /build

ENV PHP_ERROR_REPORTING=E_ALL PHP_DISPLAY_ERRORS=On PHP_MEMORY_LIMIT=512M PHP_TIMEZONE=UTC \
PHP_UPLOAD_MAX_FILESIZE=100M PHP_POST_MAX_SIZE=100M NR_INSTALL_SILENT=true NEWRELIC_ENABLED=false \
TINI_VERSION=v0.11.0 XDEBUG_ENABLED=false NEWRELIC_CLIENT=newrelic-php5-7.2.0.191-linux-musl

# Removing the standard config from the original image
RUN echo " ---> Preparing environment" && \
rm /usr/local/etc/php-fpm.d/docker.conf && rm /usr/local/etc/php-fpm.d/www.conf && \
rm /usr/local/etc/php-fpm.d/zz-docker.conf && \

# Copying our config
cp /build/www.conf /usr/local/etc/php-fpm.d/www.conf && \
cp /build/php-entrypoint.sh / && chmod +x /php-entrypoint.sh && \
cp /build/php.ini /usr/local/etc/php && \

# Instaling build dependencies
apk add --no-cache --virtual .build-deps zlib-dev openssl-dev $PHPIZE_DEPS wget ca-certificates

# Installing PHP extensions
RUN echo " ---> Installing PHP" && \
apk update && apk add bash tini postgresql-dev git && docker-php-ext-install pdo_pgsql && \
docker-php-ext-install pdo_mysql && docker-php-ext-install mbstring json && \
pecl install mongodb zip xdebug && docker-php-ext-enable mongodb

# Installing composer
RUN echo " ---> Installing Composer" && \
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
php composer-setup.php && mv composer.phar /bin/composer && \
php -r "unlink('composer-setup.php');"

# Installing nodejs and yarn (thanks facebook!)
RUN echo " ---> Installing Yarn" && \
apk add nodejs && npm install -g yarn && \

# Installing python and build base(need for node-sass)
apk add python build-base

# Installing newrelic agent
RUN echo " ---> Installing New Relic Agent" && \
wget --quiet https://download.newrelic.com/php_agent/release/$NEWRELIC_CLIENT.tar.gz -O /build/newrelic.tar.gz && \
mkdir /newrelic && tar -zxvf /build/newrelic.tar.gz -C /newrelic/ && \
/newrelic/$NEWRELIC_CLIENT/newrelic-install install

# CleanUP
RUN echo " ---> Cleaning up" && \
apk del .build-deps && \
rm -rf /build

WORKDIR /var/www/html

ENTRYPOINT ["/sbin/tini", "--", "/php-entrypoint.sh"]
