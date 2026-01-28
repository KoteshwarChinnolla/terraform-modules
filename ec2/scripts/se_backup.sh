#!/bin/bash
set -e

DIR=$(date +%d-%m-%y-%H-%M)
DEST="/mnt/data/db_backups/$DIR"

S3_BUCKET_NAME="coffeeshop-postgres-test-db"
S3_PREFIX="db_backups"

mkdir -p "$DEST"
cd "$DEST"

PGPASSWORD='koti21' pg_dump \
  --inserts \
  --column-inserts \
  --username=ec2user \
  --host=localhost \
  --port=5432 \
  testdb > dbbackup.sql

aws s3 cp dbbackup.sql "s3://$S3_BUCKET_NAME/$S3_PREFIX/$DIR/dbbackup.sql"

rm -rf "$DEST"
