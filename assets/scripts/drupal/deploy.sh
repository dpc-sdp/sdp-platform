#!/bin/sh
##
# Drupal deployment.
#

echo "==> Running database updates"
# Use this command to debug during the build process
# /app/scripts/xdebug.sh /app/vendor/bin/drush -r /app/docroot updb -y
drush updb -y
drush entup -y
echo "==> Importing Drupal configuration"
drush cim -y
drush cr -y

if [[ -z "$PERSIST_DB" ]]; then
    echo "==> Importing site-specific default content"
    drush php-eval "\$prefix = getenv('DRUPAL_MODULE_PREFIX'); module_load_install(\$prefix . '_core'); \$func = \$prefix . '_core_default_content_modules'; \$func();"
    echo "==> Enabling site-specific modules"
    drush php-eval "\$prefix = getenv('DRUPAL_MODULE_PREFIX'); module_load_install(\$prefix . '_core'); \$func = \$prefix . '_core_enable_modules'; \$func();"
fi
if [[ "$LAGOON_ENVIRONMENT_TYPE" = "production" ]] || [[ "$LAGOON_GIT_BRANCH" = "master" ]] ; then
  echo "==> Rebuilding node access permissions"
  drush php-eval "node_access_rebuild();"
  drush cr -y
fi

if [ "$DRUPAL_REFRESH_SEARCHAPI" ] && [ "$DRUPAL_REFRESH_SEARCHAPI" -ne 0 ]; then
  echo "==> Refreshing Search API"
  drush search-api-enable
  drush search-api-clear
  drush search-api-index
fi
