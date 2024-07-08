#!/bin/bash

# PostgreSQL container name
CONTAINER_NAME="test"

# PostgreSQL database user
DB_USER="test"

# PostgreSQL database name
DB_NAME="test"

# Backup destination path
BACKUP_DESTINATION="/home/maqbool/Backup"

# Date format for the backup file
DATE_FORMAT=$(date +"%Y%m%d_%H%M%S")

# Set the environment variables for PostgreSQL container
export PGPASSWORD=$(docker exec -it $CONTAINER_NAME printenv POSTGRES_PASSWORD)

# Backup the PostgreSQL database using pg_dump
docker exec -i $CONTAINER_NAME pg_dump -U $DB_USER -d $DB_NAME > $BACKUP_DESTINATION/$DB_NAME_backup_$DATE_FORMAT.sql

# Unset the environment variable
unset PGPASSWORD

echo "Backup completed successfully!"

