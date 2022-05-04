FROM oraclelinux:8
USER root
SHELL ["/bin/bash", "-c"]

# Install other useful packages
RUN dnf install -y curl wget zip

# Create required directory
RUN mkdir -p /run/php-fpm

# Install PHP 8.0, which needs a different repository
RUN dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
RUN dnf -y install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
RUN dnf -y module reset php
RUN dnf -y module enable php:remi-8.0
RUN dnf -y install php

# Install PHP extensions, including PECL with APCU and UploadProgress extensions, recommended by Drupal
RUN dnf install -y php-gd php-pdo php-zip php-mysqlnd gcc make php-devel php-pear php-pecl-apcu php-pecl-uploadprogress

# Install XDebug
RUN dnf install -y php-pecl-xdebug
RUN touch /var/log/xdebug.log
COPY /conf/xdebug.ini /etc/php.d/xdebug.ini

# Increase resources for PHP
RUN sed -i "s/max_execution_time = 30/max_execution_time = 300/g" /etc/php.ini
RUN sed -i "s/max_input_time = 60/max_input_time = 600/g" /etc/php.ini
RUN sed -i "s/memory_limit = 128M/memory_limit = 2048M/g" /etc/php.ini
RUN sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 128M/g" /etc/php.ini
RUN sed -i "s/post_max_size = 8M/post_max_size = 0/g" /etc/php.ini
RUN sed -i "s/display_errors = Off/display_errors = On/g" /etc/php.ini
RUN echo "# Increase timeout" >> /etc/httpd/conf.d/php.conf
RUN echo "Timeout 1200" >> /etc/httpd/conf.d/php.conf
RUN echo "ProxyTimeout 1200" >> /etc/httpd/conf.d/php.conf

# Update PHP-FPM configuration including allowing listeners from other clients, defining the OPCache, and listening on port 9000
RUN sed -i "s/listen.allowed_clients = 127.0.0.1/;listen.allowed_clients = 127.0.0.1/g" /etc/php-fpm.d/www.conf
RUN sed -i "s/;php_value[opcache.file_cache]  = \/var\/lib\/php\/opcache/php_value[opcache.file_cache]  = \/var\/lib\/php\/opcache/g" /etc/php-fpm.d/www.conf
RUN sed -i "s/listen = \/run\/php-fpm\/www.sock/listen = 9000/g" /etc/php-fpm.d/www.conf

# Expose the PHP-FPM port and the Xdebug port, which is accessed by the web container's Apache configuration file
EXPOSE 9000
EXPOSE 9003

# Start PHP-FPM
ENTRYPOINT ["php-fpm"]
CMD ["-F", "-R"]