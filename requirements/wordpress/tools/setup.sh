#!/bin/sh
set -e

WP_PATH="/var/www/html"

if [ -f /run/secrets/mysql_password ]; then
    MYSQL_PASSWORD=$(cat /run/secrets/mysql_password)
fi

if [ -f /run/secrets/wp_admin_password ]; then
    WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
fi

if [ -f /run/secrets/wp_user_password ]; then
    WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)
fi

until mysqladmin ping -h"mariadb" --silent; do
    sleep 1
done

if [ ! -f "$WP_PATH/wp-load.php" ]; then

    curl -fsSL https://githubusercontent.com -o /usr/local/bin/wp
    chmod +x /usr/local/bin/wp

    wp core download --version=6.9.9 --path=$WP_PATH --allow-root

    wp config create \
        --dbname="${WORDPRESS_DB_NAME}" \
        --dbuser="${WORDPRESS_DB_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb" \
        --path=$WP_PATH \
        --allow-root

    wp core install \
        --url="${WORDPRESS_URL}" \
        --title="${WORDPRESS_TITLE}" \
        --admin_user="${WORDPRESS_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WORDPRESS_ADMIN_EMAIL}" \
        --path=$WP_PATH \
        --allow-root

    wp user create \
        "${WORDPRESS_USER}" \
        "${WORDPRESS_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=author \
        --path=$WP_PATH \
        --allow-root

    chown -R www-data:www-data $WP_PATH
    chmod -R 755 $WP_PATH
else
    echo "WordPress is already installed in the volume. Skipping installation."
fi

exec php-fpm8.2 -F
