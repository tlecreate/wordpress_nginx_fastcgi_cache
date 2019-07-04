#!/bin/bash

# Change owner & file permissions
chown -R nobody:nobody /var/www/wordpress/
find /var/www/wordpress/ -type d -print0 | xargs -0 chmod 755
find /var/www/wordpress/ -type f -print0 | xargs -0 chmod 644
chmod 640 /var/www/wordpress/wp-config.php

# Enable http (recommend for localhost)
if [ "$ENABLE_HTTP" == "1" ]; then
  sed -i "s/##ENABLE_HTTP##//g" /etc/nginx/sites-available/default.conf
fi

if [ "$ENABLE_HTTPS" == "1" ]; then
  sed -i "s/##ENABLE_HTTPS##//g" /etc/nginx/sites-available/default-ssl.conf
fi

if [ "$FASTCGI_CACHE" == "1" ]; then
  sed -i "s/##FASTCGI_CACHE##//g" /etc/nginx/nginx.conf
  sed -i "s/##FASTCGI_CACHE##//g" /etc/nginx/sites-available/default.conf
  sed -i "s/##FASTCGI_CACHE##//g" /etc/nginx/sites-available/default-ssl.conf
fi

# Display PHP error's or not
if [ "$ERRORS" != "1" ]; then
  sed -i "s/;php_flag\[display_errors\] = off/php_flag[display_errors] = off/g" /etc/php7/php-fpm.d/www.conf
else
  sed -i "s/;php_flag\[display_errors\] = off/php_flag[display_errors] = on/g" /etc/php7/php-fpm.d/www.conf
  sed -i "s/display_errors = Off/display_errors = On/g" /etc/php7/php.ini
  if [ ! -z "$ERROR_REPORTING" ]; then sed -i "s/error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT/error_reporting = $ERROR_REPORTING/g" /etc/php7/php.ini; fi
  sed -i "s#;error_log = syslog#error_log = /var/log/php/error.log#g" /etc/php7/php.ini
fi

# Display Version Details or not
if [ "$HIDE_NGINX_HEADERS" == "0" ]; then
  sed -i "s/server_tokens off;/server_tokens on;/g" /etc/nginx/nginx.conf
else
  sed -i "s/expose_php = On/expose_php = Off/g" /etc/php7/php.ini
fi

# Increase the memory_limit
if [ ! -z "$PHP_MEM_LIMIT" ]; then
  sed -i "s/memory_limit = 128M/memory_limit = ${PHP_MEM_LIMIT}M/g" /etc/php7/php.ini
fi

# Increase the post_max_size
if [ ! -z "$PHP_POST_MAX_SIZE" ]; then
  sed -i "s/post_max_size = 8M/post_max_size = ${PHP_POST_MAX_SIZE}M/g" /etc/php7/php.ini
fi

# Increase the upload_max_filesize
if [ ! -z "$PHP_UPLOAD_MAX_FILESIZE" ]; then
  sed -i "s/upload_max_filesize = 2M/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}M/g" /etc/php7/php.ini
fi

# Increase the max_execution_time
if [ ! -z "$PHP_MAX_EXECUTION_TIME" ]; then
  sed -i "s/max_execution_time = 30/max_execution_time = ${PHP_MAX_EXECUTION_TIME}/g" /etc/php7/php.ini
fi

# Start supervisord and services
exec /usr/bin/supervisord -n -c /etc/supervisord.conf