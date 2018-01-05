FROM php:7.2-alpine
MAINTAINER FluxoTI <lucas.gois@fluxoti.com>

COPY . /build

ENV PHP_ERROR_REPORTING=E_ALL PHP_DISPLAY_ERRORS=On PHP_MEMORY_LIMIT=512M PHP_TIMEZONE=UTC \
PHP_UPLOAD_MAX_FILESIZE=100M PHP_POST_MAX_SIZE=100M NR_INSTALL_SILENT=true \
TINI_VERSION=v0.11.0 XDEBUG_ENABLED=false NEWRELIC_CLIENT=newrelic-php5-7.2.0.191-linux-musl

# Copying our config
RUN echo " ---> Preparing environment" && \
cp /build/php.ini /usr/local/etc/php && \
cp /build/entrypoint.sh / && chmod +x /entrypoint.sh && \

# Instaling build dependencies
apk add --no-cache --virtual .build-deps zlib-dev openssl-dev $PHPIZE_DEPS wget

# Installing PHP extensions
RUN echo " ---> Installing PHP" && \
apk update && apk add bash tini postgresql-dev git && docker-php-ext-install pdo_pgsql && docker-php-ext-install pdo_mysql && \
docker-php-ext-install mbstring json && \
pecl install mongodb zip xdebug && docker-php-ext-enable mongodb

# Installing composer
RUN echo " ---> Installing Composer" && \
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
php composer-setup.php && mv composer.phar /bin/composer && \
php -r "unlink('composer-setup.php');"

# Installing newrelic agent
RUN echo " ---> Installing New Relic Agent" && \
wget --quiet https://download.newrelic.com/php_agent/release/$NEWRELIC_CLIENT.tar.gz -O /build/newrelic.tar.gz && \
mkdir /newrelic && tar -zxvf /build/newrelic.tar.gz -C /newrelic/ && \
/newrelic/$NEWRELIC_CLIENT/newrelic-install install

# Installing supervisord
RUN echo " ---> Installing Supervisor" && \
mkdir -p /etc/supervisord/conf && apk add python=2.7.12-r0 py-pip=8.1.2-r0 && pip install supervisor && \
cp /build/supervisord.conf /etc/supervisord.conf

# Setting crontab file
RUN echo " ---> Setting up crontab" && \
rm /etc/crontabs/root && cp /build/crontab /etc/crontabs/root

# CleanUP
RUN echo " ---> Cleaning up" && \
apk del .build-deps && \
rm -rf /build

WORKDIR /var/www/html

ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]