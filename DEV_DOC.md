# Developer Documentation

## Prerequisites

Install:

- Docker Engine
- Docker Compose v2
- GNU Make

Run all commands from the repository root.

## Project configuration

Non-sensitive configuration is stored in:

```text
srcs/.env
```

This includes the domain name, database name, usernames, and WordPress settings.

Passwords are stored as Docker Compose secrets in:

```text
secrets/mysql_password.txt
secrets/wp_admin_password.txt
secrets/wp_user_password.txt
```

The files must exist before starting the project. Keep them private and use different passwords for real deployments.

The Compose file currently uses these host directories for persistent data:

```text
/home/bamdjar/data/mariadb
/home/bamdjar/data/wordpress
```

Change these paths in `srcs/docker-compose.yml` when setting up the project on another machine.

## Build and launch

Build the images:

```bash
make build
```

Build and start all services in the background:

```bash
make up
```

`make` does the same as `make up`.

The equivalent Docker Compose command is:

```bash
docker compose -f srcs/docker-compose.yml up --build -d
```

Validate the Compose file without starting containers:

```bash
make config
```

## Container commands

Show running containers:

```bash
docker compose -f srcs/docker-compose.yml ps
```

Follow logs:

```bash
docker compose -f srcs/docker-compose.yml logs -f
```

Follow one service's logs:

```bash
docker compose -f srcs/docker-compose.yml logs -f nginx
```

Stop containers:

```bash
make stop
```

Stop and remove containers and the Compose network:

```bash
make down
```

Restart the stack:

```bash
make restart
```

Open a shell in a running container when debugging:

```bash
docker compose -f srcs/docker-compose.yml exec nginx bash
docker compose -f srcs/docker-compose.yml exec wordpress bash
docker compose -f srcs/docker-compose.yml exec mariadb bash
```

The project uses bind mounts rather than named Docker volumes. `docker compose down` does not remove the data in the host directories. Back up those directories before deleting or changing them.

## Data persistence

MariaDB stores its database files on the host at:

```text
/home/bamdjar/data/mariadb
```

WordPress stores its files on the host at:

```text
/home/bamdjar/data/wordpress
```

The WordPress container mounts its directory with write access. Nginx mounts the same directory read-only so it can serve the files without modifying them.

The data survives container removal because it is stored outside the containers. To remove the project data, stop the stack first and deliberately delete the two host directories. This is destructive and should only be done after making a backup.

## Source layout

```text
srcs/docker-compose.yml                 Compose services and storage
srcs/requirements/nginx/                Nginx image and configuration
srcs/requirements/wordpress/             WordPress and PHP-FPM image
srcs/requirements/mariadb/               MariaDB image and initialization
Makefile                                Common project commands
secrets/                                Local password files
```
