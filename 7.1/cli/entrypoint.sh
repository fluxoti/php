#!/bin/bash

# Tweaking php.ini with the environment variables
sed -i "s/error_reporting = .*/error_reporting = $PHP_ERROR_REPORTING/" /usr/local/etc/php/php.ini
sed -i "s/display_errors = .*/display_errors = $PHP_DISPLAY_ERRORS/" /usr/local/etc/php/php.ini
sed -i "s/memory_limit = .*/memory_limit = $PHP_MEMORY_LIMIT/" /usr/local/etc/php/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = $PHP_UPLOAD_MAX_FILESIZE/" /usr/local/etc/php/php.ini
sed -i "s/post_max_size = .*/post_max_size = $PHP_POST_MAX_SIZE/" /usr/local/etc/php/php.ini
sed -i "s/;date.timezone.*/date.timezone = $PHP_TIMEZONE/" /usr/local/etc/php/php.ini

# Adding new relic info
if [[ $NEWRELIC_ENABLED == true ]]
then
    sed -i "s/;newrelic.enabled = .*/newrelic.enabled = true/" /usr/local/etc/php/conf.d/newrelic.ini
    sed -i "s/REPLACE_WITH_REAL_KEY/$NEWRELIC_LICENSE/" /usr/local/etc/php/conf.d/newrelic.ini
    sed -i "s/newrelic.appname = .*/newrelic.appname = \"$NEWRELIC_APPNAME\"/" /usr/local/etc/php/conf.d/newrelic.ini
fi

if [[ $XDEBUG_ENABLED == true ]]
then
    echo "zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20160303/xdebug.so" > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
fi

if [[ $RESET_DATABASE ==    true ]]
then
    php artisan migrate:reset --force
fi

if [[ $MIGRATE_DATABASE == true ]]
then
    php artisan migrate --force
fi

if [[ $SEED_DATABASE == true ]]
then
    php artisan db:seed --force
fi

/usr/sbin/crond
supervisord --configuration /etc/supervisord.conf

if [[ -z "$@" ]]
then
    tail -f /tmp/supervisord.log
else
    exec "$@"
fi

