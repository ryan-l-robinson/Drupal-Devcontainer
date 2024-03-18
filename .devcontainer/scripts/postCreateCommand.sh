#!/bin/bash

cd /opt/drupal

# TODO: errors here say that required files cannot be found
cp .devcontainer/drupal/default/settings.php web/sites/default/settings.php
cp .devcontainer/drupal/local.services.yml web/sites

# Import config
vendor/drush/drush/drush site-install -y minimal
vendor/drush/drush/drush cset -y system.site uuid "3d9878de-3355-4510-af4d-575deb24055f"
vendor/drush/drush/drush config-import -y

# Sets admin password
vendor/drush/drush/drush user:password admin "ZNB*ufm1tyz4rwc@yzk"

# Rebuild node access caches
vendor/drush/drush/drush php-eval 'node_access_rebuild();'

# Set the environment indicator
vendor/drush/drush/drush cset -y environment_indicator.indicator name "Local Docker"
vendor/drush/drush/drush cset -y environment_indicator.indicator fg_color "#ffffff"
vendor/drush/drush/drush cset -y environment_indicator.indicator bg_color "#000000"

# Rebuild cache
vendor/drush/drush/drush cr
