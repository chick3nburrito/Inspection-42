#!/bin/bash
set -eu

read_secret() {
    if [ ! -r "$1" ]; then
        echo "Missing secret: $1" >&2
        exit 1
    fi

    tr -d '\r\n' < "$1"
}

MYSQL_ROOT_PASSWORD=$(read_secret /run/secrets/db_root_password)
MYSQL_PASSWORD=$(read_secret /run/secrets/db_password)

mkdir -p /var/run/mysqld

chown -R mysql:mysql /var/run/mysqld
chown -R mysql:mysql /var/lib/mysql


if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    DATABASE_IS_NEW=true
else
    DATABASE_IS_NEW=false
fi

mysqld_safe --skip-networking &

if [ "$DATABASE_IS_NEW" = true ]; then
    until mysqladmin ping --silent; do
        sleep 1
    done
else
    until mysqladmin ping -u root -p"$MYSQL_ROOT_PASSWORD" --silent; do
        sleep 1
    done
fi

if [ "$DATABASE_IS_NEW" = true ]; then
    mysql -u root << EOF
        CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`; 
        CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
        GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%';
        ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
        FLUSH PRIVILEGES;
EOF
else
    mysql -u root -p"$MYSQL_ROOT_PASSWORD" << EOF
        CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;
        CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
        ALTER USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
        GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%';
        FLUSH PRIVILEGES;
EOF
fi

mysqladmin -u root -p"$MYSQL_ROOT_PASSWORD" shutdown

exec mysqld --user=mysql