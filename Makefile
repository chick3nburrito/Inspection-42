COMPOSE = docker compose -f srcs/docker-compose.yml


all: up

up: data
	$(COMPOSE) up --build -d

data:
	sudo mkdir -p /home/bamdjar/data/mariadb
	sudo mkdir -p /home/bamdjar/data/wordpress

build:
	$(COMPOSE) build

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

restart: down up

clean: down

.PHONY: all up data build down stop restart clean
