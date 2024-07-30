#!/bin/bash

# Contstants
webroot=/var/www/webroot

# Input
read -p "Source server: " source_server
read -p "Source path: " raw_path
read -p "Source username: " source_username

# Validation
ensure_trailing_slash() {
    local path="$1"
    if [[ "${path}" != */ ]]; then
        path="${path}/"
    fi
    echo "${path}"
}

source_path=$(ensure_trailing_slash "$raw_path")
db_file=$source_username-$(date +'%Y-%m-%dT%H%M%S%z').sql

cp $webroot/.htaccess /tmp/.htaccess
cp /var/www/webroot/ROOT/wp-config.php /tmp/wp-config.php
ssh $source_username@$source_server "cd $source_path && wp db export $db_file"
rsync -ahP --delete $source_username@$source_server:$source_path $webroot/
chmod 600 $webroot/wp-config.php
cp $webroot/.htaccess $webroot/.htaccess.bak
cp $webroot/wp-config.php $webroot/wp-config.php.bak
cp /tmp/.htaccess $webroot/.htaccess
cp /tmp/wp-config.php $webroot/wp-config.php
cd $webroot && wp db import $db_file && wp option update upload_path ''