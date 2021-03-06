#!/bin/bash

# Adjust limits
sudo sed -i -e "s/memory_limit = 128M/memory_limit = 512M/g" /etc/php8/php.ini
sudo sed -i -e "s/pm.max_children = 5/pm.max_children = 30/g" /etc/php8/php-fpm.d/www.conf

# Log levels
sudo sed -i -e "s/;log_level = notice/log_level = error/g" /etc/php8/php-fpm.conf
sudo sed -i -e 's/^access.log/;&/' /etc/php8/php-fpm.d/www.conf

# Enable zend assertions
sudo sed -i -e 's/zend.assertions = -1/zend.assertions = 1/g' /etc/php8/php.ini

echo "Aliasing $FRAMEWORK"
sudo ln -s /etc/nginx/sites/$FRAMEWORK.conf /etc/nginx/sites/enabled.conf

_term() {
  echo "Shutting down nginx"
  kill -SIGQUIT "$nginxpid"
  echo "Shutting down php-fpm"
  kill -SIGQUIT "$fpmpid"
}

# Starts NGINX!
if [[ -z "$@" ]]
then
    trap _term SIGTERM

    # Starts FPM
    php-fpm -y /etc/php8/php-fpm.conf -F -O 2>&1 &
    fpmpid=$!

    nginx &
    nginxpid=$!
    wait "$fpmpid"
    wait "$nginxpid"
else
    exec "$@"
fi
