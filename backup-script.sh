#!/bin/sh
cd /s3
file="$(date +%F_%H)${SERVER_NAME}_mysqldump.sql"
mysqldump -h ${MYSQL_HOST} -u ${MYSQL_USER} --password=${MYSQL_PASSWORD:-your_password} --all-databases > "$file"
s3cmd put --recursive --ssl . s3://${BUCKET_NAME}
rm "$file"