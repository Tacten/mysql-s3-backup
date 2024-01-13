#!/bin/sh
#Getting mysql suer and password
cd /sites/${SITE}
mysql_user=$(jq -r '.db_name' site_config.json)
mysql_password=$(jq -r '.db_password' site_config.json)
mkdir /s3/${SITE}
cd /s3/${SITE}
mkdir /s3/${SITE}/database_backups
cp -r /sites/${SITE} /s3/${SITE}/
file="$(date +%F-%H)_${SERVER_NAME}_${SITE}_mysqldump.sql"
mysqldump -h ${MYSQL_HOST} -u "$mysql_user" --password="$mysql_password" $mysql_user > "$file"
if [ $? -eq 0 ]; then
    echo "mysqldump successfull\nUploading Now...."
    s3cmd put --recursive --ssl --access_key=${ACCESS_KEY} --secret_key=${SECRET_KEY} /s3/${SITE} s3://${BUCKET_NAME}/${SITE}
    if [ $? -eq 0 ]; then
        wget http://healthchecks.tacten.link/ping/${HEALTHCHECK_SLUG} -T 10 -t 5 -O /dev/null
    fi
fi
rm "$file"