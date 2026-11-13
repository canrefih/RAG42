.DEFAULT_GOAL := help

ROOT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
ENV_FILE ?= $(ROOT_DIR)docker/.env
COMPOSE := docker compose --env-file "$(ENV_FILE)" -f "$(ROOT_DIR)docker/docker-compose.yml"
SERVICES := nginx postgres elasticsearch kibana ollama frontend backend rag

.PHONY: help up down stop logs ps config $(SERVICES)

help:
	@printf '%s\n' \
		'Setup: copy docker/.env.example to docker/.env and set POSTGRES_PASSWORD.' \
		'' \
		'make <service>       Build/start only that service, without dependencies:' \
		'                     nginx postgres elasticsearch kibana ollama frontend backend rag' \
		'make up              Build/start the entire stack with dependencies' \
		'make stop            Stop containers (optional: SERVICE=frontend)' \
		'make down            Remove stack containers/networks; preserve data volumes' \
		'make logs            Follow logs (optional: SERVICE=backend)' \
		'make ps              Show container status' \
		'make config          Validate Compose configuration' \
		'' \
		'Individual services remain on the internal network; nginx exposes localhost:8080.' \
		'Example: make frontend nginx (serves the demo UI without backend/RAG).' \
		'RAG is still a base image and needs app.py before it can run.' \
		'Override the environment file with ENV_FILE=/path/to/.env.'

$(SERVICES):
	$(COMPOSE) up --build --detach --no-deps $@

up:
	$(COMPOSE) up --build --detach

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop $(SERVICE)

logs:
	$(COMPOSE) logs --follow $(SERVICE)

ps:
	$(COMPOSE) ps

config:
	$(COMPOSE) config --quiet
