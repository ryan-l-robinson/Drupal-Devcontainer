FROM drupal:php8.2-apache
USER root
SHELL ["/bin/bash", "-c"]

# Install needed repositories and general packages, and put the php.ini in place
RUN apt-get update -y \
    && apt-get install -y wget git zip which sudo vim locales default-mysql-client docker nodejs npm \
    && apt-get upgrade -y \
    && mv /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini

# Install PHP extensions, using PECL
RUN pecl channel-update pecl.php.net \
    && pecl install apcu xdebug uploadprogress \
    && docker-php-ext-enable apcu \
    && echo "apc.enable_cli=1" >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini \
    && docker-php-ext-enable xdebug \
    && touch /var/log/xdebug.log \
    && chown www-data:www-data /var/log/xdebug.log \
    && docker-php-ext-enable uploadprogress
COPY /php /usr/local/etc/php/conf.d

# Add www-data user to sudo group, and allow those users to sudo without password
RUN usermod -a -G sudo www-data \
    && usermod -d /user/www-data www-data \
    && mkdir -p /user/www-data/.vscode-server \
    && chown -R www-data:www-data /user/www-data \
    && mkdir -p /user/www-data/.ssh \
    && chown -R www-data:www-data /user/www-data/.ssh \
    && chmod 700 -R /user/www-data/.ssh \
    && ssh-keyscan -t rsa gitlab.com >> /user/www-data/.ssh/known_hosts \
    && sed -i "s/%sudo	ALL=(ALL:ALL) ALL/%sudo	ALL=(ALL)	NOPASSWD: ALL/g" /etc/sudoers

# Fixes locale errors, must happen before Apache. This is using my locale of Canada
RUN echo "LC_ALL=en_CA.UTF-8" >> /etc/environment \
    && echo "en_CA.UTF-8 UTF-8" >> /etc/locale.gen \
    && echo "LANG=en_CA.UTF-8" > /etc/locale.conf \
    && locale-gen en_CA.UTF-8

# Apache configuration, including SSL certificates and logs
COPY /apache /etc/apache2
RUN a2enmod ssl \
    && mkdir -p /etc/apache2/certs \
    && openssl req -batch -newkey rsa:4096 -nodes -sha256 -keyout /etc/apache2/certs/example.com.key -x509 -days 3650 -out /etc/apache2/certs/example.com.crt -config /etc/apache2/certs/openssl-config.txt \
    && chown -R root:www-data /etc/apache2 \
    && chmod 770 -R /etc/apache2/certs

# Increase resources for PHP
RUN sed -i "s/max_execution_time = 30/max_execution_time = 300/g" /usr/local/etc/php/php.ini \
    && sed -i "s/max_input_time = 60/max_input_time = 600/g" /usr/local/etc/php/php.ini \
    && sed -i "s/memory_limit = 128M/memory_limit = 2048M/g" /usr/local/etc/php/php.ini \
    && sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 128M/g" /usr/local/etc/php/php.ini \
    && sed -i "s/post_max_size = 8M/post_max_size = 256M/g" /usr/local/etc/php/php.ini \
    && sed -i "s/;max_input_vars = 1000/max_input_vars = 10000/g" /usr/local/etc/php/php.ini

# Set up nicer grep results
ENV GREP_COLORS='mt=1;37;41'
COPY .bashrc /user/www-data/.bashrc

# Scripts for further actions to take on creation and attachment
COPY ./scripts/postCreateCommand.sh /postCreateCommand.sh

# Drupal configuration
COPY /drupal /web/sites

RUN chown -R www-data:www-data /opt/drupal \
    && chown www-data:www-data /postCreateCommand.sh \
    && chmod 777 /postCreateCommand.sh
