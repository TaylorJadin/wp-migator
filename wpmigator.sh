#!/bin/bash

# Contstants
WEBROOT=/var/www/webroot/ROOT

# Input
read -p "Source server: " SOURCE_SERVER
read -p "Source path: " RAW_PATH
read -p "Source username: " SOURCE_USERNAME

# Validation
ensure_trailing_slash() {
    local path="$1"
    if [[ "${path}" != */ ]]; then
        path="${path}/"
    fi
    echo "${path}"
}

SOURCE_PATH=$(ensure_trailing_slash "$RAW_PATH")
DB_FILE=$SOURCE_USERNAME-$(date +'%Y-%m-%dT%H%M%S%z').sql

cp $WEBROOT/.htaccess /tmp/.htaccess
cp $WEBROOT/ROOT/wp-config.php /tmp/wp-config.php
ssh $SOURCE_USERNAME@$SOURCE_SERVER "cd $SOURCE_PATH && wp db export $DB_FILE"
rsync -ahP --delete $SOURCE_USERNAME@$SOURCE_SERVER:$SOURCE_PATH $WEBROOT/
chmod 600 $WEBROOT/wp-config.php
cp $WEBROOT/.htaccess $WEBROOT/.htaccess.bak
cp $WEBROOT/wp-config.php $WEBROOT/wp-config.php.bak
cp /tmp/.htaccess $WEBROOT/.htaccess
cp /tmp/wp-config.php $WEBROOT/wp-config.php
cd $WEBROOT && wp db import $DB_FILE && wp option update upload_path ''
ssh $SOURCE_USERNAME@$SOURCE_SERVER "cd $SOURCE_PATH && rm $DB_FILE"