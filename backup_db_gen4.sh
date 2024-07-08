#!/bin/bash

current_date=$(date +"%Y-%m-%d")
output_file="test_backup_${current_date}.sql"

db_user="test"
db_host="127.0.0.1"
db_port="5432"
db_name="test"
db_password="password"

PGPASSWORD="${db_password}" pg_dump -U "${db_user}" -h "${db_host}" -p "${db_port}" "${db_name}" > "${output_file}"
echo "Backup of database ${db_name} is sucessfully created as ${output_file}"

destination_user="test"
destination_host="192.168.1.111"
destination_directory="/home/test/Production_DB_Backup"

sshpass -p 'test' scp "${output_file}" "${destination_user}@${destination_host}:${destination_directory}"

#rm "${output_file}"

