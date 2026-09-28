COMPOSE = docker compose -f srcs/docker-compose.yml


all: up

up:
	$(COMPOSE) up --build -d

build:
	$(COMPOSE) build

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

restart: down up

clean: down

config:
	$(COMPOSE) config

	
.PHONY: all up build down stop restart clean config
