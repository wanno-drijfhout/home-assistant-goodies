#!/usr/bin/with-contenv bashio

db_name=$(bashio::config "db_name")
db_username=$(bashio::config "db_username")
db_password=$(bashio::config "db_password")

DocumentRoot=/share/wordpress
echo "Document root: ${DocumentRoot}."
if [ ! -d $DocumentRoot ]; then
    mkdir -p $DocumentRoot
    cd $DocumentRoot

    echo "Downloading new WordPress installation..."
    curl -L -s "https://wordpress.org/latest.tar.gz" \
      | tar zxf - --strip 1 -C $DocumentRoot

    echo "Adapting configuration..."
    cp /wp-config.php .
    sed -i "s/database_name_here/${db_name}/g" wp-config.php
    sed -i "s/username_here/${db_username}/g" wp-config.php
    sed -i "s/password_here/${db_password}/g" wp-config.php
    sed -i "s/localhost/core_mariadb:3306/g" wp-config.php
    
    # Step 1: Remove the existing block and leave a placeholder
    sed -i '\~/**#@+~,\~/**#@-~c\
    /* PLACEHOLDER */' wp-config.php

    # Step 2: Query the secret-key service and store the result in a variable
    KEYS_AND_SALTS=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)

    # Step 3: Replace the placeholder with the new keys and salts
    sed -i '/\/\* PLACEHOLDER \*\//{
    r /dev/stdin
    d
    }' wp-config.php <<< "$KEYS_AND_SALTS"






    
    echo "Configured."
else
    echo "Found existing folder"
fi

rm -rf /var/www/localhost/htdocs
ln -s $DocumentRoot /var/www/localhost/htdocs

mkdir /usr/lib/php81/modules/opcache

echo "Starting Apache2..."
exec /usr/sbin/httpd -D FOREGROUND