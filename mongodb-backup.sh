#!/bin/bash

# Settings
DB_HOST="$MONGO_HOST"
DB_NAME="$MONGO_DATABASE"
DB_USER="$MONGO_USER"
DB_PASS="$MONGO_PASS"
BUCKET_NAME="$BUCKET"
PD_TOKEN="$PAGERDUTY_TOKEN"

# Path in which to create the backup (will get cleaned later)
BACKUP_PATH="/mnt/data/dump/"

CURRENT_DATE=$(date +"%Y%m%d-%H%M")

# Backup filename
BACKUP_FILENAME="$DB_NAME-$CURRENT_DATE.tar.gz"

# Create the backup
mongodump -h "$DB_HOST" -d "$DB_NAME" -u "$DB_USER" -p "$DB_PASS" -o "$BACKUP_PATH" || curl -X POST --header ‘Content-Type: application/json' --header 'Accept: application/vnd.pagerduty+json;version=2' --header 'From: admin@idecisiongames.com' --header 'Authorization: Token token="$PD_TOKEN"' -d '{"incident":{"type":"incident","title":"IDG Backup failed.","service":{"id":"PONW4BQ","type":"service_reference"}}}' 'https://api.pagerduty.com/incidents'
cd $BACKUP_PATH || exit

# Archive and compress
tar -cvzf "$BACKUP_PATH""$BACKUP_FILENAME" ./*

# Copy to Google Cloud Storage
echo "Copying $BACKUP_PATH$BACKUP_FILENAME to gs://$BUCKET_NAME/$DB_NAME/"
/root/gsutil/gsutil cp "$BACKUP_PATH""$BACKUP_FILENAME" gs://"$BUCKET_NAME"/"$DB_NAME"/ 2>&1
echo "Copying finished"
echo "Removing backup data"
rm -rf $BACKUP_PATH*
