#!/bin/bash

# Variables
BACKUP_DIR="backup"

DEST_PATH="landing/*/"


# Limit the number of backups to 3
echo "Limiting the number of backups to 3"
BACKUPS=$(gsutil ls $BUCKET_NAME/backups/ | grep 'world_' | sort)
BACKUP_COUNT=$(echo "$BACKUPS" | wc -l)

if [ "$BACKUP_COUNT" -gt 3 ]; then
  BACKUPS_TO_DELETE=$(echo "$BACKUPS" | head -n -3)
  for BACKUP in $BACKUPS_TO_DELETE; do
    echo "Deleting old backup: $BACKUP"
    gsutil rm "$BACKUP"
  done
fi
