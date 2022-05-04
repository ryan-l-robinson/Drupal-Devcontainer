#!/bin/bash

# Enforce strict permissions on id_rsa key, required to use git
sudo chown -R drupal:drupal /home/drupal/.ssh
chmod -R 700 ~/.ssh

# Provide ownership of entire web root to drupal user
sudo chown -R drupal:apache /var/www/html

# Move to codebase
cd /var/www/html/local.drupal.com

# Add local domain to hosts file (useful for tools like pa11y being able to browse the site)
if [ ! -z $(grep "127.0.0.1 local.drupal.com" /etc/hosts) ]; then
  echo "127.0.0.1 local.drupal.com" >> /etc/hosts
fi

# Create database and grant all privileges to drupal user
mysql --host="db" -e "CREATE DATABASE IF NOT EXISTS drupal;" -u root --password="root"
mysql --host="db" -e "GRANT ALL PRIVILEGES ON drupal.* TO 'drupal'@'%';" -u root --password="root"

# Install site's contributed code base from composer
composer install --prefer-dist

# Add drush alias to PATH
echo "alias drush=\"/var/www/html/local.drupal.com/vendor/drush/drush/drush\"" >> ~/.bashrc

# Copy the Drupal files
if [[ -f ./.devcontainer/conf/drupal.settings.php ]]
then
  sudo cp .devcontainer/conf/drupal.settings.php web/sites/default/settings.php
fi
if [[ ! -d private ]]
then
  mkdir private
  chmod 755 private
fi
if [[ ! -d sync/config ]]
then
  mkdir -p sync/config
fi

# Import config
vendor/drush/drush/drush site-install -y minimal
vendor/drush/drush/drush cset -y system.site uuid "3d9878de-3355-4510-af4d-575deb24055f"
vendor/drush/drush/drush config-import -y
vendor/drush/drush/drush image-flush --all

# Sets admin password
vendor/drush/drush/drush user:password admin "ZNB*ufm1tyz4rwc@yzk"

# Find homepage and set it again, since node IDs will be different after content sync
home_id=$(vendor/drush/drush/drush sql-query 'SELECT nid FROM node_field_data where type="home" and status="1" and title="Home" limit 1;')
if [[ ! -z ${home_id} ]]
then
  vendor/drush/drush/drush cset -y system.site page.front /node/$home_id
fi

# Rebuild node access caches
vendor/drush/drush/drush php-eval 'node_access_rebuild();'

# Set the environment indicator
vendor/drush/drush/drush cset -y environment_indicator.indicator name "Local Docker"
vendor/drush/drush/drush cset -y environment_indicator.indicator fg_color "#ffffff"
vendor/drush/drush/drush cset -y environment_indicator.indicator bg_color "#000000"

# Rebuild cache
vendor/drush/drush/drush cr