#!/bin/bash
set -eu

DATA_DIR=/var/lib/mysql
SOCKET_DIR=/run/mysqld
SOCKET="$SOCKET_DIR/mysqld.sock"
MYSQL_PASSWORD=$(cat /run/secrets/mysql_password)

if [ -z "$MYSQL_PASSWORD" ]; then
	echo "MariaDB password secret is empty" >&2
	exit 1
fi

mkdir -p "$SOCKET_DIR" "$DATA_DIR"
chown -R mysql:mysql "$SOCKET_DIR" "$DATA_DIR"

if [ ! -d "$DATA_DIR/mysql" ]; then
	mariadb-install-db --user=mysql --datadir="$DATA_DIR" --skip-test-db
fi

mariadbd --user=mysql --datadir="$DATA_DIR" --skip-networking --socket="$SOCKET" &
TEMP_SERVER_PID=$!

cleanup() {
	if kill -0 "$TEMP_SERVER_PID" 2>/dev/null; then
		mariadb-admin --socket="$SOCKET" shutdown || true
		wait "$TEMP_SERVER_PID" || true
	fi
}
trap cleanup EXIT

until mariadb-admin --socket="$SOCKET" ping >/dev/null 2>&1; do
	sleep 1
done

if [ ! -f "$DATA_DIR/.inspection42-configured" ]; then
	mariadb --socket="$SOCKET" <<-SQL
		CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
		CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
		GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
		FLUSH PRIVILEGES;
	SQL
	touch "$DATA_DIR/.inspection42-configured"
	chown mysql:mysql "$DATA_DIR/.inspection42-configured"
fi

mariadb-admin --socket="$SOCKET" shutdown
wait "$TEMP_SERVER_PID" || true
trap - EXIT

exec mariadbd --user=mysql --datadir="$DATA_DIR" --bind-address=0.0.0.0
