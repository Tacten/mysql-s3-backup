#!/bin/sh
#Getting mysql user and password
mkdir -p /s3/${SITE}/uploads
mkdir -p /s3/${SITE}/database_backups
cd /s3/

tar -zcvf /s3/${SITE}/uploads.gz /uploads
file="/s3/${SITE}/database_backups/$(date +%F-%H)_${SERVER_NAME}_${DB}_postgres.sql.gz"
pg_dumpall -U plane | gzip > ${file}
if [ $? -eq 0 ]; then
    echo "postgresql dump successfull\nUploading Now...."
    s3cmd put --recursive --ssl --access_key=${ACCESS_KEY} --secret_key=${SECRET_KEY} /s3/${SITE} s3://${BUCKET_NAME}/
    if [ $? -eq 0 ]; then
        wget http://healthchecks.tacten.link/ping/${HEALTHCHECK_SLUG} -T 10 -t 5 -O /dev/null
    fi
fi
rm -r /s3/${SITE}/*