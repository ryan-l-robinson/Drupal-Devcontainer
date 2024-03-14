FROM drupal:php8.1-apache
USER root
SHELL ["/bin/bash", "-c"]

# Install needed repositories and general packages, after putting the php.ini in place
RUN apt-get update \
    && apt-get upgrade -y \
    && mv /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini \
    && apt-get install -y wget git zip which sudo vim locales default-mysql-client docker nodejs npm

# Add playwright/axe accessibility testing tools.
RUN npm install playwright @axe-core/playwright @playwright/test fsp-xml-parser \
    && npm init playwright@latest --yes -- --quiet --browser=chromium --browser=firefox --browser=webkit --lang=ts \
    && npx playwright install --with-deps chromium firefox webkit \
    && rm /opt/drupal/tests/example.spec.ts
# The example test is generated but we don't want it, so removing it again with line above.
ENV BASE_URL="https://local.library.wlu.ca"
ENV SITEMAP_PATH="/opt/drupal/web/sites/default/files/xmlsitemap/NXhscRe0440PFpI5dSznEVgmauL25KojD7u4e9aZwOM/1.xml"

# Install PHP extensions, using PECL
RUN pecl channel-update pecl.php.net \
    && pecl install apcu xdebug uploadprogress \
    && docker-php-ext-enable apcu \
    && echo "apc.enable_cli=1" >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini \
    && docker-php-ext-enable xdebug \
    && touch /var/log/xdebug.log \
    && chown www-data:www-data /var/log/xdebug.log \
    && docker-php-ext-enable uploadprogress
COPY .devcontainer/php /usr/local/etc/php/conf.d

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

# Fixes locale errors, must happen before Apache
RUN echo "LC_ALL=en_CA.UTF-8" >> /etc/environment \
    && echo "en_CA.UTF-8 UTF-8" >> /etc/locale.gen \
    && echo "LANG=en_CA.UTF-8" > /etc/locale.conf \
    && locale-gen en_CA.UTF-8

# Apache configuration, including SSL certificates and logs
COPY .devcontainer/apache /etc/apache2
RUN a2enmod ssl \
    && mkdir -p /etc/apache2/certs \
    && openssl req -batch -newkey rsa:4096 -nodes -sha256 -keyout /etc/apache2/certs/library.wlu.ca.key -x509 -days 3650 -out /etc/apache2/certs/library.wlu.ca.crt -config /etc/apache2/certs/openssl-config.txt \
    && chown -R root:www-data /etc/apache2 \
    && chmod 770 -R /etc/apache2/certs

# Assign correct permissions on the web root
COPY --chown=www-data:www-data .. /opt/drupal
COPY --chown=www-data:www-data .devcontainer/drupal /opt/drupal/web/sites
COPY --chown=www-data:www-data scripts /opt/drupal/scripts
RUN chown -R www-data:www-data /var/www \
    && chown -R www-data:www-data /opt \
    && chmod -R 770 /opt/drupal/scripts
# I don't know why it requires the extra chown after already setting it within the ADD, but it does

# Increase resources for PHP
RUN sed -i "s/max_execution_time = 30/max_execution_time = 300/g" /usr/local/etc/php/php.ini \
    && sed -i "s/max_input_time = 60/max_input_time = 600/g" /usr/local/etc/php/php.ini \
    && sed -i "s/memory_limit = 128M/memory_limit = 2048M/g" /usr/local/etc/php/php.ini \
    && sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 128M/g" /usr/local/etc/php/php.ini \
    && sed -i "s/post_max_size = 8M/post_max_size = 256M/g" /usr/local/etc/php/php.ini \
    && sed -i "s/;max_input_vars = 1000/max_input_vars = 10000/g" /usr/local/etc/php/php.ini

# Set up nicer grep results
ENV GREP_COLORS='mt=1;37;41'
COPY .devcontainer/.bash_profile /user/www-data/.bash_profile

# Copy the ALC usernames sample file
COPY .devcontainer/conf/libraryusername.csv /var/alc/libraryusername.csv
RUN chown www-data:www-data /var/alc/libraryusername.csv \
    && chmod 644 /var/alc/libraryusername.csv

# Get and build the Drupal code, with proper permissions
USER www-data
RUN cd /opt/drupal \
    && composer install
