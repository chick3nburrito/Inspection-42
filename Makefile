COMPOSE_FILE := ./srcs/docker-compose.yml
DATA_DIR ?= /home/bamdjar/data

all: up

up:
	DATA_DIR=$(DATA_DIR) docker compose -f $(COMPOSE_FILE) up --build -d

build:
	docker compose -f $(COMPOSE_FILE) build

down:
	docker compose -f $(COMPOSE_FILE) down

stop:
	docker compose -f $(COMPOSE_FILE) stop

restart: down up

logs:
	docker compose -f $(COMPOSE_FILE) logs -f

clean: down

fclean: clean
	docker system prune -af

re: fclean all

config:
	docker compose -f $(COMPOSE_FILE) config

.PHONY: all up build down stop restart logs clean fclean re config
