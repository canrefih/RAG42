# Testing the development stack

This guide verifies the infrastructure, React demo chat, and Django hello-world
endpoint. It does **not** verify end-to-end RAG or LLM functionality: the RAG
service has no application source, and the frontend returns a fixed demo reply.

## Prerequisites

- Docker Engine running with the Docker Compose plugin.
- GNU Make.
- Node.js 26 and npm for the frontend tests.
- Available host ports: `8080` for nginx and `5601` for Kibana by default.

Run all commands from the repository root. Service definitions are in
[docker-compose.yml](../docker/docker-compose.yml); shortcuts are in the
[Makefile](../Makefile).

## 1. Configure the environment

Create the environment file without overwriting an existing file:

```bash
make setup
```

Set a unique `POSTGRES_PASSWORD` in [docker/.env](../docker/.env).
If the file already exists but is empty, populate it using the settings in
[.env.example](../docker/.env.example).

Validate the configuration:

```bash
make config
```

Expected: the command exits successfully. A missing password must be fixed
before starting the services. Do not commit the environment file.

## 2. Start the implemented services

```bash
make start
make ps
```

`make start` builds and starts everything except the unfinished RAG service,
waiting up to 180 seconds for container health checks. Individual service targets
such as `make frontend` still start only that service, without its dependencies.

Expected:

- All seven services remain running, not restarting or exited.
- PostgreSQL, Elasticsearch, and Ollama eventually report `healthy`.
- Kibana may need additional startup time after Elasticsearch becomes healthy.

Do not use `make up` yet: it includes RAG, whose missing entrypoint prevents it
from running.

## 3. Check the browser and public API

| Check | Default address | Expected result |
|-------|-----------------|-----------------|
| React frontend through nginx | <http://localhost:8080> | Chat page loads |
| Demo conversation | Send a message on the chat page | User message and a clearly labeled fixed demo reply appear |
| Chat scrolling | Send enough messages to fill the screen, then scroll through history | Only the conversation scrolls; the page stays viewport-height and the header and composer remain visible |
| Kibana | <http://localhost:5601> | Kibana loads after initialization |
| Django through nginx | <http://localhost:8080/api/> | HTTP 200 with the JSON below |

```bash
make check-api
```

Expected: `API through nginx: OK`. This verifies HTTP 200 and the exact response:

```json
{"message":"Hello world!","service":"backend"}
```

Use the configured ports instead if you changed `HTTP_PORT` or `KIBANA_PORT`.
Backend port `8000` and frontend port `3000` are internal container ports, not
published host ports.

## 4. Run automated tests and infrastructure checks

### Frontend

```bash
make test-frontend
```

Expected: both chat tests pass, TypeScript checks succeed, and Vite produces a
production build.

The tests cover sending messages, rejecting whitespace-only messages, suggested
prompts, multiline input, rendering HTML as text, and resetting the conversation.

### Run all automated tests

No application services need to be running for these tests:

```bash
make test
```

This installs frontend dependencies, tests and builds the frontend, then builds
the backend image and runs isolated Django system checks and tests. The
environment file must still be configured for Compose.

### Run all live checks

After `make start`:

```bash
make check
```

This checks the frontend and API through nginx, the Django database connection,
Elasticsearch cluster health, Kibana availability, and Ollama. A failed check
returns a nonzero exit status. Kibana can take longer to initialize; inspect its
logs and rerun `make check-kibana` when ready.

The HTTP checks run inside the backend container on the Compose network, so they
do not depend on host ports or a host installation of `curl`. Check the browser
addresses above separately to verify host access.

### Django

```bash
make test-backend
```

Expected: no system-check issues and five passing endpoint tests.
These tests do not require a live database; test database connectivity separately.

### Django to PostgreSQL

```bash
make check-db
```

Expected: `Database connected`. This checks the actual database credentials and
network connection from Django, not just container readiness.

### Elasticsearch

```bash
make check-elasticsearch
```

Expected: cluster status is `green` or `yellow`, not `red`. A single-node
development cluster can be yellow because replicas cannot be assigned.

### Ollama

```bash
make check-ollama
```

Expected: the command succeeds. An empty model list is normal before downloading
a model. This checks Ollama availability, not model inference.

### Other development shortcuts

| Command | Purpose |
|---------|---------|
| `make help` | List available commands |
| `make build` | Build all application Docker images without starting services |
| `make build SERVICE=backend` | Build only the backend image |
| `make pull` | Pull third-party images, skipping locally built applications |
| `make frontend-install` | Install frontend dependencies from the lockfile |
| `make frontend-dev` | Install dependencies and launch Vite on port 3000 |
| `make frontend-build` | Install dependencies, type-check, and build the frontend |
| `make check-frontend` | Verify nginx serves the frontend HTML |
| `make check-kibana` | Verify Kibana reports available |
| `make migrate` | Apply Django migrations against the running PostgreSQL service |
| `make restart SERVICE=backend` | Restart the existing backend container without rebuilding |

Use `make backend` after backend source or image changes to rebuild and recreate
the container. `make restart` alone does not update an image.

All Compose targets accept `ENV_FILE=/path/to/.env` to select another environment
file. No command in this guide deletes stored data volumes.

## 5. Diagnose failures

```bash
make ps
make logs SERVICE=backend
```

Replace `backend` with the failing service. Press `Ctrl+C` to stop following logs;
this does not stop the container.

| Symptom | Next check |
|---------|------------|
| Missing password or interpolation error | Populate `POSTGRES_PASSWORD` in the environment file, then run `make config` |
| Port already allocated | Change `HTTP_PORT` or `KIBANA_PORT`, then rerun the corresponding service target |
| nginx returns 502 for `/` | Check `make logs SERVICE=frontend` and verify the frontend is running |
| nginx returns 502 for `/api/` | Check `make logs SERVICE=backend` and verify Django started |
| Elasticsearch is unhealthy | Inspect `make logs SERVICE=elasticsearch` for resource or host-setting requirements |
| Kibana is not ready | Confirm Elasticsearch is healthy, then inspect `make logs SERVICE=kibana` |
| Database connection fails | Check PostgreSQL health and credentials; changing the password variable does not change an existing database password |
| RAG repeatedly exits | RAG is only a base image; leave it stopped until its application exists |

This stack uses PostgreSQL 18. Existing PostgreSQL 17 database files require a
proper migration; do not reuse an old data directory as if it were compatible.
Do not delete data volumes as a troubleshooting shortcut.

## 6. Shut down

```bash
make down
```

This removes stack containers and networks while preserving named data volumes.

To stop only one service without removing containers:

```bash
make stop SERVICE=backend
```

## What remains untested

Passing these checks verifies the development scaffold. It does not establish:

- Document ingestion, indexing, or retrieval.
- Model inference or generated answers.
- Frontend-to-backend chat requests.
- Backend-to-RAG communication or end-to-end chat.

Those checks need to be added when the corresponding application code exists.
