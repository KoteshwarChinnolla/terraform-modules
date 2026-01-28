#!/bin/bash
set -e

# Create the backup file
TIME=$(date --utc "+%Y%m%d_%H%M%SZ")

# Use the timestamp to construct a descriptive file name
BACKUP_FILE="backup-pg-${TIME}.pgdump"
S3_PREFIX="db_backups"
DATABASE_NAME="testdb"
HOST="localhost"
PORT=5432
USERNAME="ec2user"
S3_BUCKET_NAME="coffeeshop-postgres-test-db"

pg_dump $DATABASE_NAME -h $HOST -p $PORT -U $USERNAME -w --format=custom > $BACKUP_FILE

# -h host
# -p port
# -U username
# -w this avoids a password prompt and refers .pgpass file for password

# Second, copy file to AWS S3
S3_BUCKET=s3://$S3_BUCKET_NAME
S3_TARGET=$S3_BUCKET/$S3_PREFIX/$BACKUP_FILE
echo "Copying $BACKUP_FILE to $S3_TARGET"
aws s3 cp $BACKUP_FILE $S3_TARGET

# verify the backup was uploaded correctly
echo "Backup completed for $DATABASE_NAME"
BACKUP_RESULT=$(aws s3 ls $S3_BUCKET | tail -n 1)
echo "Latest S3 backup: $BACKUP_RESULT"

# clean up and delete the local backup file
rm $BACKUP_FILE


# pg_restore -h $HOST -p $PORT -U $USERNAME -d $DATABASE_NAME --format=custom /tmp/$BACKUP_FILE