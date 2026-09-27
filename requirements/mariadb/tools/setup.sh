#!/bin/bash
set -e

MYSQL_PASSWORD=$(cat /run/secrets/mysql_password)

sleep 3

service mariadb start

mysql -u root -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
mysql -u root -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
mysql -u root -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"
mysql -u root -e "FLUSH PRIVILEGES;"

service mariadb stop

exec mysqld_safe
