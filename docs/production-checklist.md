# Production deployment checklist

The current configuration is a local-development scaffold, **not ready for
production**. This checklist describes changes still needed; it does not apply
them or certify the deployment as secure.

Use the [Docker reference](docker.md) for existing endpoints and the
[testing guide](testing.md) for current checks. The items below are based on
[Compose](../docker/docker-compose.yml), the
[gateway configuration](../docker/nginx.conf), application Dockerfiles, and
[Django settings](../srcs/backend/config/settings.py).

## Release blockers

- [ ] Implement the RAG application: its Dockerfile currently starts a missing
  `app.py`. Do not deploy a container that continuously restarts.
- [ ] Replace the frontend's fixed demo reply with a tested chat API integration.
  Implement backend-to-RAG-to-Ollama communication, error handling, cancellation,
  and bounded conversation/context sizes.
- [ ] Implement ingestion, indexing, retrieval, and source attribution if the
  release is intended to provide document-grounded answers.
- [ ] Select and provision a supported model before declaring inference ready.
  Check its license, provenance, resource needs, and expected answer quality.
- [ ] Define who may access the application and documents. The current backend
  only has a public hello-world route; there is no user authentication or
  document-level authorization.

## 1. Public entry point and nginx

Current configuration: HTTP only, a catch-all `server_name _`, and a loopback
binding on port `8080`.

- [ ] Choose the production domain and TLS termination point: gateway nginx,
  ingress, or an external load balancer.
- [ ] Configure certificates, automatic renewal, HTTPS redirects, and appropriate
  HSTS after verifying the HTTPS configuration. Keep HTTP available only for
  deliberate redirects or certificate validation.
- [ ] Replace the catch-all application virtual host with explicit domains and
  reject unexpected hostnames at the edge.
- [ ] Decide whether nginx stays loopback-only behind another proxy or publishes
  production listener ports. Do not expose every container port to achieve this.
- [ ] Establish a trusted proxy chain. The current gateway sets
  `X-Forwarded-Proto` from its own `$scheme`; an external TLS terminator would
  otherwise make Django see HTTP. Accept forwarded headers only from trusted
  infrastructure and prevent clients from spoofing them.
- [ ] Set request-body limits, request/read/send timeouts, connection limits, and
  rate limits appropriate for chat and document uploads.
- [ ] Align nginx, Gunicorn, application-client, and inference timeouts. `/api/`
  currently has no custom read timeout or streaming configuration.
- [ ] If streaming is implemented, test buffering, client disconnects, idle
  timeouts, and worker capacity on the actual chat route.
- [ ] Preserve the internal-only RAG boundary: RAG has no public proxy route or
  published host port. Enforce authentication,
  authorization, and validation in the backend before forwarding requests.
  Segment networks so frontend/gateway containers cannot directly access RAG.
- [ ] Apply suitable security headers to API and error responses as well as
  static files. Preserve and test the frontend's existing Content Security
  Policy; do not weaken it just to make an integration work.

## 2. Secrets and Django configuration

Current configuration: passwords are interpolated from a local environment file,
and Django generates a new secret key at process startup when none is provided.

- [ ] Supply a strong, stable `DJANGO_SECRET_KEY` through managed secret storage.
  Make production startup fail explicitly if the secret is missing instead of
  generating a replacement. Plan controlled rotation.
- [ ] Wire `DJANGO_SECRET_KEY` and `DJANGO_ALLOWED_HOSTS` into the backend
  container. They are read by Python but are **not passed by Compose today**;
  putting them in the Compose environment file alone is insufficient.
- [ ] Set `ALLOWED_HOSTS` to intended production hostnames. Account for internal
  health probes without using a wildcard.
- [ ] Keep `DEBUG=False`; add production settings for secure cookies,
  `CSRF_TRUSTED_ORIGINS`, SSL redirects, and HSTS as appropriate.
  `SECURE_PROXY_SSL_HEADER` is safe only after establishing the trusted proxy
  behavior described above.
- [ ] Keep CSRF protection for cookie-authenticated requests and implement a
  proper token flow. Do not disable CSRF to connect the chat UI.
- [ ] Add authentication and authorization before accepting private data or
  costly inference requests. Enable required Django applications/middleware if
  using Django sessions and authentication; they are not installed today.
- [ ] Keep same-origin requests where possible. If separate frontend/API origins
  are required, configure a narrow CORS policy rather than allowing all origins.
- [ ] Replace example passwords and administrator identities. Use separate
  secrets for PostgreSQL, pgAdmin, Elastic service accounts, and application
  signing.
- [ ] Use a secret manager or restricted mounted secret files; add application
  support for reading them where necessary. Compose secrets alone do not make
  an application consume file-based credentials automatically.
- [ ] Restrict production configuration access, avoid secrets in logs or images,
  and document rotation. Database and pgAdmin bootstrap passwords do not reset
  existing persisted accounts when environment values change.
- [ ] Run Django's deployment checks against the actual production settings and
  resolve applicable warnings:

  ```bash
  docker compose -f docker/docker-compose.yml exec backend python manage.py check --deploy
  ```

  Use the production Compose files and environment when they exist; the command
  above targets the current development definition.

## 3. PostgreSQL

Current configuration: the Django connection uses `POSTGRES_USER`, which the
official PostgreSQL image creates as a database superuser during initialization.

- [ ] Separate bootstrap/administration credentials from the Django runtime
  account. Grant the runtime account only the permissions it needs; consider a
  separate migration role.
- [ ] Configure and verify encrypted database connections where required by the
  deployment boundary, using certificate verification rather than just enabling
  encryption without identity checks.
- [ ] Size storage, connections, and connection pooling for measured workload.
  Define disk-space alerts and maintenance procedures.
- [ ] Run migrations as an explicit, controlled deployment step with failure
  handling and backward-compatible rollout planning.
- [ ] Implement scheduled backups, retention, off-host storage, and tested
  restores. A named Docker volume is not a backup.
- [ ] Define recovery objectives and choose managed PostgreSQL or replication
  and failover if the availability requirement calls for it.
- [ ] Keep the PostgreSQL 18 mount layout and plan supported major-version
  migrations. Never point a new major version at incompatible existing files.

## 4. Elasticsearch and Kibana

Current configuration: Elasticsearch security is disabled, Kibana has no login,
all connections use HTTP, Elasticsearch is single-node, and its JVM heap is
fixed at 512 MiB.

- [ ] Enable Elasticsearch security and configure authenticated access.
- [ ] Configure TLS and certificate trust for Elasticsearch HTTP and, when
  applicable, node-to-node transport; update every client to use the intended
  encrypted endpoints.
- [ ] Give Kibana a supported service credential and configure user login with
  appropriate roles. Do not use the Elasticsearch superuser as the application
  or Kibana service identity.
- [ ] Use scoped credentials for indexing and retrieval, with access limited to
  the required indices and operations.
- [ ] Set persistent Kibana encryption keys for the features in use, including
  session/security, saved objects, and reporting where applicable.
- [ ] Restrict Kibana to a private administration network, VPN, or authenticated
  access proxy. Keep it out of the public application path.
- [ ] Replace `discovery.type: single-node` if high availability is required.
  Define node discovery, replicas, storage placement, and failure-domain policy.
  Single-node operation is an explicit availability tradeoff, not automatic HA.
- [ ] Size heap, memory limits, storage, and host settings using the selected
  Elastic version's requirements and measured indexing/query load.
- [ ] Configure index mappings, lifecycle/retention, disk alerts, and snapshots
  to a supported external repository. Test restoration.
- [ ] Update health checks and Make checks for TLS and authentication without
  exposing credentials. Current checks assume unauthenticated HTTP.

## 5. pgAdmin and administration access

Current configuration: pgAdmin is included in normal startup, published on
loopback port `5050`, and initialized with a local email/password pair.

- [ ] Decide whether pgAdmin belongs on the production host at all. Prefer
  optional administration tooling rather than an application dependency.
- [ ] If retained, isolate it behind a VPN or private administration ingress;
  require HTTPS and controlled administrative access.
- [ ] Replace the example email and bootstrap password. Define user provisioning,
  credential rotation, and MFA/SSO where supported by the chosen authentication
  setup.
- [ ] Protect its persistent volume and saved connection information. Avoid
  saving privileged database passwords unnecessarily.
- [ ] Remove pgAdmin from mandatory application readiness if it becomes optional.

Loopback publishing does not replace authentication, and all containers currently
share a network that permits access to the administration services internally.

## 6. Ollama, RAG, and data boundaries

Current configuration: Ollama has no application authentication layer, runs
CPU-only, and starts without a model. RAG has only a base Dockerfile.

- [ ] Keep Ollama private; never publish its API publicly without an authenticated,
  authorized gateway. Restrict which services can reach it.
- [ ] Provision approved model versions reproducibly and verify model readiness,
  not merely whether `ollama list` succeeds.
- [ ] Benchmark CPU versus GPU requirements. If using a GPU, configure supported
  drivers/runtime and explicit device access rather than privileged containers.
- [ ] Set limits for prompt size, output tokens, context length, concurrency,
  queue length, and request duration. Provide overload responses and cancellation.
- [ ] Define model-loading behavior and storage capacity; do not download models
  unexpectedly during user requests.
- [ ] Implement tenant/document access checks before retrieval, so one user's
  indexed content cannot be returned to another without authorization.
- [ ] Treat uploaded documents and retrieved text as untrusted input. Validate
  file types and sizes, constrain parsers and ingestion jobs, and prevent
  retrieved instructions from granting tools or broader data access.
- [ ] Define retention, deletion, and privacy rules for documents, embeddings,
  prompts, responses, and logs. Verify deletion across PostgreSQL, Elasticsearch,
  uploaded-file storage, and backups according to policy.
- [ ] If inference or ingestion uses external providers later, explicitly review
  what data leaves the deployment and obtain the necessary approvals.

## 7. Container networking and runtime

Current configuration: all services use one default bridge network, no
per-service resource limits are set, and restart policies are the main recovery
mechanism.

- [ ] Segment frontend/gateway, application, database/search, inference, and
  administration traffic according to actual access needs.
- [ ] Restrict outbound access where practical. The current network is not
  configured as `internal: true`; apply isolation deliberately and accommodate
  model provisioning or other necessary egress.
- [ ] Keep PostgreSQL, Elasticsearch, Ollama, and internal application ports
  unpublished. Expose only the chosen public and private administration ingress.
- [ ] Add tested CPU, memory, process, and storage limits; align worker counts and
  heap sizes with those limits.
- [ ] Apply least privilege: drop unnecessary capabilities, prevent privilege
  escalation, and use read-only filesystems with explicit writable mounts where
  supported. Test each upstream image's requirements instead of forcing a
  configuration that breaks initialization.
- [ ] Preserve the existing non-root application runtimes. Assess gateway and
  third-party image permissions separately; do not assume every upstream image
  supports the same user or filesystem restrictions.
- [ ] Add graceful shutdown budgets for in-flight generation and ingestion.
  `restart: unless-stopped` alone neither guarantees availability nor restarts a
  container merely because its health status becomes unhealthy.

## 8. Builds, versions, and deployment workflow

Current configuration: Compose builds application images locally, third-party
images use version tags, npm has a lockfile, and Python direct dependencies are
pinned without a complete transitive lock.

- [ ] Create a production deployment definition or carefully scoped override;
  keep local defaults separate and document exactly which files deploy.
- [ ] Build/test images in CI, publish to a registry, and deploy immutable image
  digests. Avoid compiling application code on the production host.
- [ ] Pin base/service images by digest and establish a reviewed update schedule.
  Numeric tags can still change; "latest available" is not a compatibility policy.
- [ ] Lock Python transitive dependencies reproducibly and verify artifacts.
  Preserve `npm ci` and the frontend lockfile.
- [ ] Add dependency/image scanning, software inventories, and license checks to
  CI. Keep supported, tested versions rather than performing unverified major
  upgrades in production.
- [ ] Review Docker build contexts and exclusions. RAG currently lacks a
  `.dockerignore`; prevent future credentials, virtual environments, caches, and
  local data from being copied into images.
- [ ] Tune Gunicorn workers, worker class, connection handling, and timeouts for
  the implemented workload. The current command uses defaults suited only to
  the simple hello-world endpoint, not concurrent long-running chat.
- [ ] Add production startup/readiness checks for the gateway, frontend, backend,
  RAG, and Kibana. Distinguish process liveness, traffic readiness, and external
  dependency checks to avoid restart storms.
- [ ] Replace development `make start` semantics for production: it explicitly
  skips RAG and dependency ordering. Ensure all intended services are ready,
  with application retries for transient dependency failures.
- [ ] Define rollout, rollback, migration, and recovery procedures. Compose on
  one host is not a multi-host high-availability deployment.

## 9. Monitoring, backups, and release validation

- [ ] Collect structured logs with correlation/request IDs and bounded retention.
  Configure Docker log rotation; avoid logging secrets or private prompt/document
  contents by default.
- [ ] Monitor HTTP error rates and latency, model load/generation latency, queue
  depth, memory/GPU use, disk space, database health, and index health.
- [ ] Configure actionable alerts and an operational owner for incidents.
- [ ] Back up PostgreSQL and Elasticsearch independently; include application
  uploads and pgAdmin state if needed. Define whether models are restored or
  downloaded from verified sources. Encrypt backups and restrict their access.
- [ ] Test restores and loss of a container/host. Persistent local volumes do not
  survive every host or disk failure.
- [ ] Add end-to-end chat and retrieval tests, authenticated access tests,
  cross-user data isolation tests, and upload/input-limit tests.
- [ ] Test unavailable dependencies, missing models, timeouts, client
  cancellation, overload, and graceful shutdown.
- [ ] Load-test the complete production path, including TLS/proxies, with realistic
  prompt sizes and concurrent requests.
- [ ] Update `make check` or add production-specific checks. Current checks assume
  HTTP, development hostnames, unauthenticated Elastic/Kibana, and a hello-world
  API response; a passing development check is not production acceptance.
- [ ] Confirm browser behavior, TLS renewal, backup restoration, access controls,
  monitoring, and rollback in staging before exposing real users or data.

## Existing choices to preserve

- `DEBUG=False` and Django's existing security/CSRF middleware.
- Non-root frontend, backend, and RAG application runtimes.
- A production static frontend build, rather than a public Vite development server.
- Unpublished database/search/inference ports and loopback-only administration
  bindings unless replaced with deliberately secured ingress.
- Ignored local environment files and persistence across `make down`.

The deployment target, expected traffic, data sensitivity, and availability
requirements determine the final design. Complete and verify the applicable
checklist items rather than treating this document as a ready-to-run production
configuration.
