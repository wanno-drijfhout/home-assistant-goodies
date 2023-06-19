#!/usr/bin/with-contenv bashio

DocumentRoot=/share/wordpress
echo "Document root: ${DocumentRoot}."
if [ ! -d $DocumentRoot ]; then
    mkdir -p $DocumentRoot
    cd $DocumentRoot

    echo "Downloading new WordPress installation..."
    curl -L -s "https://wordpress.org/latest.tar.gz" \
      | tar zxvf - --strip 1 -C $DocumentRoot

    echo "Adapting configuration..."
    cp /wp-config.php .
    sed -i 's/database_name_here/(bashio::config "db_name")/g' /var/www/localhost/htdocs/wp-config.php
    sed -i 's/username_here/(bashio::config "db_username")/g' /var/www/localhost/htdocs/wp-config.php
    sed -i 's/password_here/(bashio::config "db_password")/g' /var/www/localhost/htdocs/wp-config.php
    sed -i 's/localhost/core_mariadb:3306/g' /var/www/localhost/htdocs/wp-config.php
    curl -s https://api.wordpress.org/secret-key/1.1/salt/ \
       | sed -e '/\/\*\*#@+\*/,/\/\*\*#@-\*\//d' -e '/\/\*\*#@-\*\//r /dev/stdin' -i /var/www/localhost/htdocs/wp-config.php 
    
    echo "Configured."
else
    echo "Found existing folder"
fi

rm -rf /var/www/localhost/htdocs
ln -s $DocumentRoot /var/www/localhost/htdocs

mkdir /usr/lib/php81/modules/opcache

echo "Starting Apache2..."
exec /usr/sbin/httpd -D FOREGROUND