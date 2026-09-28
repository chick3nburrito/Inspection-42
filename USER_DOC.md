# User Documentation

## Services

This project provides a WordPress website with three services:

- **Nginx**: receives HTTPS requests from your browser.
- **WordPress/PHP-FPM**: runs the WordPress application.
- **MariaDB**: stores the WordPress data.

## Start the project

From the repository root, run:

```bash
make
```

Or use Docker Compose directly:

```bash
docker compose -f srcs/docker-compose.yml up --build -d
```

## Stop the project

To stop and remove the containers and network:

```bash
make down
```

To stop the containers without removing them:

```bash
make stop
```

The website and database data are stored on the host, so stopping or recreating the containers does not remove that data.

## Access the website

Add this line to `/etc/hosts` if the domain does not resolve locally:

```text
127.0.0.1 bamdjar.42.fr
```

Open the website at:

```text
https://bamdjar.42.fr
```

The certificate is self-signed, so your browser may show a security warning.

The WordPress administration panel is available at:

```text
https://bamdjar.42.fr/wp-admin
```

The administrator username is defined by `WP_ADMIN_USER` in `srcs/.env`. The administrator password is stored in `secrets/wp_admin_password.txt`.

## Credentials

Non-sensitive usernames and configuration are in:

```text
srcs/.env
```

Passwords are stored in:

```text
secrets/mysql_password.txt
secrets/wp_admin_password.txt
secrets/wp_user_password.txt
```

Keep these files private. Do not publish their contents or commit real production passwords.

## Check the services

Show the container status:

```bash
docker compose -f srcs/docker-compose.yml ps
```

View all service logs:

```bash
docker compose -f srcs/docker-compose.yml logs -f
```

View logs for one service:

```bash
docker compose -f srcs/docker-compose.yml logs -f nginx
# Replace nginx with wordpress or mariadb when needed.
```

A healthy setup should show running `nginx`, `wordpress`, and `mariadb` containers, and the website should open over HTTPS.
