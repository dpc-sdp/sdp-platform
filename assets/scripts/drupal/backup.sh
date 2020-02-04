#!/bin/sh
##
# Pre deployment db backup for %%PROJECT_NAME%%.
#

DATE_WITH_TIME=`date "+%Y%m%d-%H%M%S"`
BACKUP_DIR="/app/docroot/sites/default/files/private/"
BACKUP_FILE="pre_deploy_backup"
RETENTION_DAYS=1

#backup database
mkdir -p ${BACKUP_DIR}
drush sql-dump --gzip --result-file=${BACKUP_DIR}${BACKUP_FILE}.sql


#add time stamp to the backup files
mv ${BACKUP_DIR}${BACKUP_FILE}.sql.gz ${BACKUP_DIR}${BACKUP_FILE}.${DATE_WITH_TIME}.sql.gz

# remove files older than 1 day
find ${BACKUP_DIR} -type f -name "${BACKUP_FILE}*.sql.gz" -mtime ${RETENTION_DAYS} -exec rm {} \;
