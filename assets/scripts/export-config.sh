#!/bin/sh
##
# Rebuild environment.
#

# Fetch prod db.
./scripts/drush-download-db.sh

# Import db.
./scripts/drupal/import-db.sh

echo "==> Enabling SDP required modules"
# TODO: Make this configurable
drush en tide_publication baywatch -y
drush en tide_alert -y

echo "==> Running database updates"
# Use this command to debug during the build process
# /app/scripts/xdebug.sh /app/vendor/bin/drush -r /app/docroot updb -y
drush updb -y

echo "==> Exporting config"
drush cex -y
