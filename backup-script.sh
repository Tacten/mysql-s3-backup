#!/bin/sh
cd /s3
file="$(date +%F-%H)_${SERVER_NAME}_${SITE}_mysqldump.sql"
mysqldump -h ${MYSQL_HOST} -u ${MYSQL_USER} --password=${MYSQL_PASSWORD:-your_password} ${DATABASE} > "$file"
if [ $? -eq 0 ]; then
    echo "mysqldump successfull\nUploading Now...."
    s3cmd put --recursive --ssl --access_key=${ACCESS_KEY} --secret_key=${SECRET_KEY} . s3://${BUCKET_NAME}/${SITE}
    if [ $? -eq 0 ]; then
        wget http://healthchecks.tacten.link/ping/${HEALTHCHECK_SLUG} -T 10 -t 5 -O /dev/null
    fi
fi
rm "$file"