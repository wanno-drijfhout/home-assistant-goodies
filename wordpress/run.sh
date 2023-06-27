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
    sed -i "s/localhost/core-mariadb:3306/g" wp-config.php
    
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

    echo "Setting writing permissions for apache..."
    chown -R 100:101 .
    
    echo "Adding .htaccess..."
    cp /.htaccess .

    echo "Enabling PHP extensions..."
    echo "extension=exif" > /etc/php81/conf.d/01_exif.ini
    echo "extension=imagick" > /etc/php81/conf.d/02_imagick.ini
    mkdir /usr/lib/php81/modules/opcache # Don't know why this is needed, but just copied it
else
    echo "Found existing folder"
fi

echo "Changing PHP configuration..."
sed -i 's/^post_max_size = .*/post_max_size = 64M/' /etc/php81/php.ini
sed -i 's/^upload_max_filesize = .*/upload_max_filesize = 32M/' /etc/php81/php.ini

echo "Linking and owning Apache document root..."    
rm -rf /var/www/localhost/htdocs
ln -s $DocumentRoot /var/www/localhost/htdocs
chown -R 100:101 /var/www/localhost  # Apache ids

echo "Changing Apache configuration..."
sed -i 's/^#LoadModule rewrite_module modules\/mod_rewrite.so/LoadModule rewrite_module modules\/mod_rewrite.so/' /etc/apache2/httpd.conf
sed -i '/<Directory "\/var\/www\/localhost\/htdocs">/,/AllowOverride None/ s/AllowOverride None/AllowOverride All/' /etc/apache2/httpd.conf


echo "Starting Apache2..."
exec /usr/sbin/httpd -D FOREGROUND