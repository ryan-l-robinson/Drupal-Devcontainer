FROM oraclelinux:8
USER root
SHELL ["/bin/bash", "-c"]

# Install other needed packages
RUN dnf install -y curl wget git zip mod_ssl httpd php-gd openssl which mariadb sudo patch vim

# Apache configuration, including SSL certificates and logs
RUN mkdir -p /etc/httpd/certs
COPY /conf/openssl-config.txt /etc/httpd/certs/openssl-config.txt
RUN openssl req -batch -newkey rsa:4096 -nodes -sha256 -keyout /etc/httpd/certs/local.drupal.com.key -x509 -days 3650 -out /etc/httpd/certs/local.drupal.com.crt -config /etc/httpd/certs/openssl-config.txt
RUN openssl req -batch -newkey rsa:4096 -nodes -sha256 -keyout /etc/pki/tls/private/localhost.key -x509 -days 3650 -out /etc/pki/tls/certs/localhost.crt -config /etc/httpd/certs/openssl-config.txt
RUN mkdir -p /var/log/local.drupal.com
COPY /conf/local.drupal.com.conf /etc/httpd/conf.d/local.drupal.com.conf

# Add drupal user within the apache group
RUN useradd drupal
RUN usermod -aG apache drupal
# Change default permissions to 775 instead of 755, so that the drupal user can write to the web root
RUN umask 0002
# Create sudo group, add drupal user to it, and allow those users to sudo without password
RUN groupadd sudo
RUN usermod -aG sudo drupal
RUN sed -i "s/# %wheel	ALL=(ALL)	NOPASSWD: ALL/%sudo	ALL=(ALL)	NOPASSWD: ALL/g" /etc/sudoers

# Install PHP 8.0, which needs a different repository
RUN dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
RUN dnf -y install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
RUN dnf -y module reset php
RUN dnf -y module enable php:remi-8.0
RUN dnf -y install php

# Install PHP extensions, including PECL with APCU and UploadProgress extensions, recommended by Drupal
RUN dnf install -y php-pdo php-zip php-mysqlnd gcc make php-devel php-pear php-pecl-apcu php-pecl-uploadprogress

# Increase resources for PHP
RUN sed -i "s/max_execution_time = 30/max_execution_time = 300/g" /etc/php.ini
RUN sed -i "s/max_input_time = 60/max_input_time = 600/g" /etc/php.ini
RUN sed -i "s/memory_limit = 128M/memory_limit = 2048M/g" /etc/php.ini
RUN sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 128M/g" /etc/php.ini
RUN sed -i "s/post_max_size = 8M/post_max_size = 256M/g" /etc/php.ini
RUN sed -i "s/display_errors = Off/display_errors = On/g" /etc/php.ini
RUN echo "# Increase timeout" >> /etc/httpd/conf.d/php.conf
RUN echo "Timeout 1200" >> /etc/httpd/conf.d/php.conf
RUN echo "ProxyTimeout 1200" >> /etc/httpd/conf.d/php.conf

# Install latest composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir /usr/bin --filename composer
RUN php -r "unlink('composer-setup.php');"
ENV COMPOSER_PROCESS_TIMEOUT=9999

# Install pa11y accessibility testing tool, including NodeJS
RUN dnf install -y nodejs pango.x86_64 libXcomposite.x86_64 libXdamage.x86_64 libXext.x86_64 libXi.x86_64 libXtst.x86_64 cups-libs.x86_64 libXScrnSaver.x86_64 libXrandr.x86_64 GConf2.x86_64 alsa-lib.x86_64 atk.x86_64 gtk3.x86_64 nss libdrm libgbm xorg-x11-fonts-100dpi xorg-x11-fonts-75dpi xorg-x11-utils xorg-x11-fonts-cyrillic xorg-x11-fonts-Type1 xorg-x11-fonts-misc libxshmfence
RUN npm install pa11y -g --unsafe-perm=true --allow-root

# Install XDebug
RUN dnf install -y php-pecl-xdebug
RUN touch /var/log/xdebug.log
RUN chown drupal:drupal /var/log/xdebug.log
COPY /conf/xdebug.ini /etc/php.d/xdebug.ini

# Scripts for further actions to take on creation and attachment
COPY ./scripts/postCreateCommand.sh /postCreateCommand.sh
RUN ["chmod", "+x", "/postCreateCommand.sh"]

# Expose Apache and MySQL
EXPOSE 80
EXPOSE 443

# Start Apache
ENTRYPOINT ["/usr/sbin/httpd"]
CMD ["-D", "FOREGROUND"]
