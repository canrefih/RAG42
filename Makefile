.DEFAULT_GOAL := help

ROOT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
ENV_FILE ?= $(ROOT_DIR)docker/.env
COMPOSE := docker compose --env-file "$(ENV_FILE)" -f "$(ROOT_DIR)docker/docker-compose.yml"
SERVICES := nginx postgres pgadmin elasticsearch kibana ollama frontend backend rag
IMPLEMENTED_SERVICES := $(filter-out rag,$(SERVICES))
FRONTEND_DIR := $(ROOT_DIR)srcs/frontend

.PHONY: help setup start up down stop restart logs ps config build pull \
	frontend-install frontend-dev frontend-build test test-frontend test-backend \
	check check-frontend check-api check-db check-elasticsearch check-kibana \
	check-ollama check-pgadmin migrate $(SERVICES)

help:
	@printf '%s\n' \
		'make setup           Create the environment file without overwriting it' \
		'                     Then set POSTGRES_PASSWORD and PGADMIN_DEFAULT_PASSWORD in docker/.env.' \
		'' \
		'make start           Build/start implemented services; wait for health checks' \
		'make <service>       Build/start only that service, without dependencies:' \
		'                     nginx postgres pgadmin elasticsearch kibana ollama frontend backend rag' \
		'make up              Build/start the entire stack INCLUDING unfinished RAG' \
		'make build           Build Docker images (optional: SERVICE=backend)' \
		'make pull            Pull third-party images (optional: SERVICE=postgres)' \
		'make stop            Stop containers (optional: SERVICE=frontend)' \
		'make restart         Restart existing containers (optional: SERVICE=backend)' \
		'make down            Remove stack containers/networks; preserve data volumes' \
		'make logs            Follow logs (optional: SERVICE=backend)' \
		'make ps              Show container status' \
		'make config          Validate Compose configuration' \
		'' \
		'make test            Run frontend tests/build and isolated Django tests' \
		'make test-frontend   Install npm dependencies, run chat tests and build/type-check' \
		'make test-backend    Build backend image, run Django checks/tests (no services needed)' \
		'make check           Check live UI, API, database, pgAdmin, Elasticsearch, Kibana and Ollama' \
		'                     Run make start first; Kibana may need extra startup time.' \
		'make check-<name>    Run one live check: frontend api db pgadmin elasticsearch kibana ollama' \
		'make migrate         Apply Django migrations against the running database' \
		'' \
		'make frontend-install  Install frontend npm dependencies from the lockfile' \
		'make frontend-dev      Install dependencies and start Vite on port 3000' \
		'make frontend-build    Install dependencies and build/type-check locally' \
		'' \
		'Individual services remain on the internal network; nginx exposes localhost:8080.' \
		'Example: make frontend nginx (serves the demo UI without backend/RAG).' \
		'RAG is still a base image and needs app.py before it can run.' \
		'Override the environment file with ENV_FILE=/path/to/.env.'

setup:
	@if [ -e "$(ENV_FILE)" ]; then \
		printf '%s\n' 'Environment file already exists; left unchanged. Ensure POSTGRES_PASSWORD and PGADMIN_DEFAULT_PASSWORD are set.'; \
	else \
		cp "$(ROOT_DIR)docker/.env.example" "$(ENV_FILE)" && \
		printf '%s\n' 'Environment file created. Set unique POSTGRES_PASSWORD and PGADMIN_DEFAULT_PASSWORD values before starting.'; \
	fi

$(SERVICES):
	$(COMPOSE) up --build --detach --no-deps $@

start:
	$(COMPOSE) up --build --detach --no-deps --wait --wait-timeout 180 $(IMPLEMENTED_SERVICES)

up:
	$(COMPOSE) up --build --detach

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop $(SERVICE)

restart:
	$(COMPOSE) restart $(SERVICE)

build:
	$(COMPOSE) build $(SERVICE)

pull:
	$(COMPOSE) pull --ignore-buildable $(SERVICE)

logs:
	$(COMPOSE) logs --follow $(SERVICE)

ps:
	$(COMPOSE) ps

config:
	$(COMPOSE) config --quiet

frontend-install:
	cd "$(FRONTEND_DIR)" && npm ci

frontend-dev: frontend-install
	cd "$(FRONTEND_DIR)" && npm run dev

frontend-build: frontend-install
	cd "$(FRONTEND_DIR)" && npm run build

test: test-frontend test-backend

test-frontend: frontend-install
	cd "$(FRONTEND_DIR)" && npm test && npm run build

test-backend:
	$(COMPOSE) build backend
	$(COMPOSE) run --rm --no-deps -T backend python manage.py check
	$(COMPOSE) run --rm --no-deps -T backend python manage.py test

check: check-frontend check-api check-db check-pgadmin check-elasticsearch check-kibana check-ollama

check-frontend:
	$(COMPOSE) exec -T backend python -c 'import urllib.request; r = urllib.request.urlopen("http://nginx/", timeout=10); assert r.status == 200 and b"<title>RAG42" in r.read(); print("Frontend through nginx: OK")'

check-api:
	$(COMPOSE) exec -T backend python -c 'import json, urllib.request; r = urllib.request.urlopen("http://nginx/api/", timeout=10); assert r.status == 200 and json.load(r) == {"message": "Hello world!", "service": "backend"}; print("API through nginx: OK")'

check-db:
	$(COMPOSE) exec -T backend python manage.py shell -c 'from django.db import connection; connection.ensure_connection(); print("Database connected")'

check-pgadmin:
	$(COMPOSE) exec -T pgadmin /venv/bin/python3 -c 'import urllib.request; r = urllib.request.urlopen("http://127.0.0.1/misc/ping", timeout=10); assert r.status == 200; print("pgAdmin: OK")'

check-elasticsearch:
	$(COMPOSE) exec -T backend python -c 'import json, urllib.request; r = urllib.request.urlopen("http://elasticsearch:9200/_cluster/health", timeout=10); status = json.load(r)["status"]; print("Elasticsearch:", status); assert status in ("green", "yellow"), "Elasticsearch cluster is not ready"'

check-kibana:
	$(COMPOSE) exec -T backend python -c 'import json, urllib.request; r = urllib.request.urlopen("http://kibana:5601/api/status", timeout=10); level = json.load(r)["status"]["overall"]["level"]; print("Kibana:", level); assert level == "available", "Kibana is not ready"'

check-ollama:
	$(COMPOSE) exec -T ollama ollama list

migrate:
	$(COMPOSE) run --rm --no-deps -T backend python manage.py migrate
