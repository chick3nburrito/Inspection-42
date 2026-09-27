#!/bin/bash
set -eu

MYSQL_PASSWORD=$(cat /run/secrets/mysql_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)
DB_HOST=${WORDPRESS_DB_HOST%%:*}
DB_PORT=${WORDPRESS_DB_HOST##*:}

if [ -z "$MYSQL_PASSWORD" ] || [ -z "$WP_ADMIN_PASSWORD" ] || [ -z "$WP_USER_PASSWORD" ]; then
	echo "A required WordPress secret is empty" >&2
	exit 1
fi

if [ ! -f /var/www/html/index.php ]; then
	cp -a /usr/src/wordpress/. /var/www/html/
	chown -R www-data:www-data /var/www/html
fi

until mariadb -h "$DB_HOST" -P "$DB_PORT" \
	-u"$WORDPRESS_DB_USER" \
	-p"$MYSQL_PASSWORD" \
	-e "SELECT 1" >/dev/null 2>&1; do
	sleep 2
done

if [ ! -f /var/www/html/wp-config.php ]; then
	wp config create --allow-root \
		--dbname="$WORDPRESS_DB_NAME" \
		--dbuser="$WORDPRESS_DB_USER" \
		--dbpass="$MYSQL_PASSWORD" \
		--dbhost="$WORDPRESS_DB_HOST" \
		--path=/var/www/html
fi

if ! wp core is-installed --allow-root --path=/var/www/html; then
	wp core install --allow-root \
		--url="https://${DOMAIN_NAME}" \
		--title="$WP_TITLE" \
		--admin_user="$WP_ADMIN_USER" \
		--admin_password="$WP_ADMIN_PASSWORD" \
		--admin_email="$WP_ADMIN_EMAIL" \
		--path=/var/www/html

	wp user create --allow-root \
		"$WP_USER_NAME" "$WP_USER_EMAIL" \
		--role=author \
		--user_pass="$WP_USER_PASSWORD" \
		--path=/var/www/html
fi

exec php-fpm8.2 -F
