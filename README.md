*This project has been created as part of the 42 curriculum by bamdjar*

# Inception

## Description

Inception is a 42 project that builds a small web infrastructure from scratch with Docker Compose. The goal is to understand containerization, service isolation, networking, persistent storage, secrets, and the interaction between a web server, an application runtime, and a database.

The project contains three containers:

- **Nginx**: the HTTPS entry point and reverse proxy. It serves static files and forwards PHP requests to WordPress through FastCGI.
- **WordPress with PHP-FPM**: the CMS and PHP application. It installs and configures WordPress, executes PHP code, and communicates with MariaDB.
- **MariaDB**: the relational database that stores WordPress users, posts, settings, and other application data.

The services are built from Debian Bookworm-based Dockerfiles rather than being run from pre-built application images. Their source files are in `srcs/requirements/`:

- `srcs/requirements/nginx/`: Nginx Dockerfile, TLS setup, and Nginx configuration.
- `srcs/requirements/wordpress/`: PHP-FPM Dockerfile, WP-CLI installation, PHP-FPM configuration, and WordPress initialization script.
- `srcs/requirements/mariadb/`: MariaDB Dockerfile, server configuration, and database initialization script.
- `srcs/docker-compose.yml`: service definitions, network, secrets, ports, and persistent storage.
- `secrets/`: password files supplied to the containers through Docker Compose secrets.

### Main design choices

Each service runs in its own container and has one main foreground process. Nginx exposes HTTPS on port `443`; WordPress exposes PHP-FPM internally on port `9000`; and MariaDB is reachable only by the other services through the Compose bridge network. Startup scripts perform one-time initialization and use `exec` to replace themselves with the real service process, so the service receives Docker signals correctly as PID 1.

WordPress files and MariaDB data are persisted outside the containers. Nginx mounts the WordPress directory read-only, while the WordPress container can write to it during installation and runtime.

### Virtual Machines vs Docker

| Virtual machines | Docker containers |
|---|---|
| Virtualize a complete guest operating system, including its own kernel. | Share the host kernel while isolating processes, filesystems, and networks. |
| Usually require more memory, disk space, and startup time. | Are lightweight, start quickly, and use fewer resources. |
| Provide strong OS-level isolation and can run a different kernel or operating system. | Provide process-level isolation and package each service with its dependencies. |
| This project would need one VM or several VMs to host the infrastructure. | This project uses one container per service, making the architecture explicit and reproducible. |

Docker is appropriate here because the project focuses on deploying independent services with reproducible environments without the overhead of full virtual machines.

### Secrets vs Environment Variables

Environment variables are convenient for non-sensitive configuration such as the domain name, database name, WordPress title, and usernames. They are visible through container configuration and should not be used for passwords when a safer mechanism is available.

Docker Compose secrets provide password files mounted inside the containers under `/run/secrets/`. This project uses secrets for the MariaDB root password, the WordPress database password, and the WordPress user passwords. The initialization scripts read those files only when needed. The secret files are kept in the repository's `secrets/` directory for this local project and must be protected from publication or accidental exposure.

### Docker Network vs Host Network

A Docker bridge network gives containers private connectivity and service-name DNS, so WordPress can reach MariaDB at `mariadb` and Nginx can reach PHP-FPM at `wordpress:9000`. Only Nginx publishes a host port.

Host networking would place containers directly on the host network namespace. It can offer slightly less network overhead, but it removes much of Docker's network isolation, can cause port conflicts, and makes service discovery less explicit. The project therefore uses the `inception` bridge network.

### Docker Volumes vs Bind Mounts

A Docker-managed volume is created and controlled by Docker. It is portable between hosts using Docker's volume commands and avoids depending on a particular host directory layout.

A bind mount maps a specific host path into a container. It makes data easy to inspect and back up directly from the host, but the path must exist and permissions must be correct on that host. This project uses bind mounts for `/home/bamdjar/data/mariadb` and `/home/bamdjar/data/wordpress` so database and WordPress data remain available after containers are recreated. These paths may need to be changed for another machine.

## Instructions

### Prerequisites

Install and start:

- Docker Engine
- Docker Compose v2 (`docker compose`)
- GNU Make

The commands below are run from the repository root.

### Configuration

1. Create or review `srcs/.env` with the non-sensitive settings used by Compose and the initialization scripts.
2. Ensure these files exist and contain passwords:

   - `secrets/mysql_password.txt`
   - `secrets/wp_admin_password.txt`
   - `secrets/wp_user_password.txt`

3. Check the bind-mount paths in `srcs/docker-compose.yml`. Create them if necessary or replace `/home/bamdjar/data/` with a suitable path for your machine.
4. Add the domain to `/etc/hosts` so the local site resolves:

   ```text
   127.0.0.1 bamdjar.42.fr
   ```

The Nginx container creates a self-signed certificate for `bamdjar.42.fr`, so a browser will display a certificate warning during local testing.

### Build and run

Start the complete infrastructure and build the images:

```bash
make
```

The equivalent Docker Compose command is:

```bash
docker compose -f srcs/docker-compose.yml up --build -d
```

Open `https://bamdjar.42.fr` in a browser. The first startup can take time while WordPress waits for MariaDB and performs its initial installation.

### Useful commands

```bash
make build      # Build the images
make up         # Start the services in detached mode
make down       # Stop and remove the containers and network
make stop       # Stop containers without removing them
make restart    # Stop and start the infrastructure again
make config     # Validate and display the Compose configuration
```

To inspect service status and logs:

```bash
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs -f
```

### Use of AI

AI was used to help diagnose and fix the **502 Bad Gateway** issue, including checking the communication between Nginx and PHP-FPM and reviewing the related Docker and WordPress configuration

## Resources

- [Dockerfile reference](https://docs.docker.com/reference/dockerfile/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [Docker Compose secrets](https://docs.docker.com/compose/how-tos/use-secrets/)
- [Docker networking overview](https://docs.docker.com/engine/network/)
- [Docker storage and bind mounts](https://docs.docker.com/engine/storage/)
- [Nginx documentation](https://nginx.org/en/docs/)
- [PHP-FPM documentation](https://www.php.net/manual/en/install.fpm.php)
- [WordPress Developer Resources](https://developer.wordpress.org/)
- [MariaDB documentation](https://mariadb.com/docs/)
- [42 Inception subject](https://cdn.intra.42.fr/pdf/pdf/133789/en.subject.pdf)