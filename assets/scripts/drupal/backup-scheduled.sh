#!/bin/sh
##
# Pre deployment db backup.
#

# Check that all variables are present
if [ -z "$1" ]; then
  echo "Please provide the location of Drupal root for this project."
  exit 2
fi

if [ -z "$2" ]; then
  echo "Please provide a backup prefix. This will be used at the start of the backup file name and should be a few characters indicating the project the backup is for."
  exit 2
fi

# The location of the Drupal root folder
LOCAL=$1
# Get the location for the private and public files folders from Drupal
PRIVATE_FILES=$(drush -r ${LOCAL} dd private)
PUBLIC_FILES=$(drush -r ${LOCAL} dd files)
BACKUPS_NAME_PREFIX=$2
BACKUPS=${PRIVATE_FILES}/backups
BACKUP_DATE=$(date +"%Y%m%d%H%M")
HOUR=$(date +"%H")
DB_FILE_NAME=${BACKUPS}/${BACKUPS_NAME_PREFIX}_${BACKUP_DATE}.sql
BACKUP_FILE_NAME=${BACKUPS}/${BACKUPS_NAME_PREFIX}_${BACKUP_DATE}.tar.gz

# Dump the database, gzip it, then encrypt it
mkdir -p ${BACKUPS}
mkdir -p ${BACKUPS}/retain
drush -r ${LOCAL} sql-dump --result-file=${DB_FILE_NAME}
gzip ${DB_FILE_NAME}
# If specified, also backup the files
if [ "$3" = "true" ]; then
    tar -czpf ${BACKUP_FILE_NAME} ${DB_FILE_NAME}.gz ${PUBLIC_FILES} ${PRIVATE_FILES}
else
    tar -czpf ${BACKUP_FILE_NAME} ${DB_FILE_NAME}.gz
fi
openssl enc -aes-256-cbc -salt -in ${BACKUP_FILE_NAME} -out ${BACKUP_FILE_NAME}.enc -pass pass:$ENCPASS
rm ${BACKUP_FILE_NAME}
if [ $HOUR = "01" ]; then
    mv ${BACKUPS}/${BACKUP_FILE_NAME}.enc ${BACKUPS}/retain
fi

# Cleaning up old files
cd ${BACKUPS}
ls -p | grep -v / | head -n -6 | xargs rm || echo "no backups to clean up"
cd ${BACKUPS}/retain
ls -p | grep -v / | head -n -7 | xargs rm || echo "no backups to clean up"
