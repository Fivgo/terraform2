#!/bin/bash

# Variables
BACKUP_DIR="backup"

DEST_PATH="landing/*/"

# Find the most recent backup file
LATEST_BACKUP=$(ls -t $BACKUP_DIR | tail -n 1)

# Check if a backup file was found
if [ -z "$LATEST_BACKUP" ]; then
  echo "No backup files found in $BACKUP_DIR"
  exit 1
fi

# Full path to the latest backup file
LATEST_BACKUP_PATH="$BACKUP_DIR/$LATEST_BACKUP"

# Copy the latest backup file to the GCP bucket
gsutil cp $LATEST_BACKUP_PATH gs://$BUCKET_NAME/$DEST_PATH
gsutil ls gs://e1015-bucket-clie2/backups | sort | tail -n ${1:-1}
# Check if the copy was successful
if [ $? -eq 0 ]; then
  echo "Successfully copied $LATEST_BACKUP_PATH to gs://$BUCKET_NAME/$DEST_PATH"
else
  echo "Failed to copy $LATEST_BACKUP_PATH to gs://$BUCKET_NAME/$DEST_PATH"
  exit 1
fi