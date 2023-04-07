## 1. About

#### 1.1. Hypha is a SPDM system that allows to manage data and simulations, run computational tasks and process the results
#### 1.2. User guide could be found here: [Hypha & Hub User Guide](https://mycesys.com/hypha/2023.1/userguide.pdf)
#### 1.3. This document describes the complete guide to install desired version of Hypha

## 2. Prerequisites

#### 2.1. [Docker](https://docs.docker.com/engine/) & [docker-compose](https://docs.docker.com/compose/)
#### 2.2. [OpenSSL](https://www.openssl.org/)
#### 2.3. Trusted SSL certificate for https

- https is required for OAuth2 protocol and browser support for secure hash algorithms
- If you don’t have SSL certificate you can get it for free from https://letsencrypt.org/

#### 2.4. Internet access to [Docker Hub](https://hub.docker.com)

## 3. System requirements

#### 3.1. Hardware requirements

- <50 users

| Node | CPU | RAM | Disk |
| -------- | ------ | ------- | ------ |
| All in one | 16 | 64 | 512 Gb | 

- 100+ users

| Node | CPU | RAM | Disk |
| -------- | ------ | ------- | ------ |
| Hub | 4 | 16 | 60 Gb |
| Core | 8 | 24 | 60 Gb |
| Task manager | 8 | 16 | 60 Gb |
| Resource manager| 8 | 16 | 60 Gb | 
| Workflow | 4 | 16 | 60 Gb |
| BFF | 4 | 16 | 60 Gb |
| Dashboard | 4 | 16 | 60 Gb |
| Files | 4 | 24 | 512 Gb |
| Gateway | 4 | 16 | 60 Gb |

- Size and type of storage depends on planned number of users,  simulations, solver, average model size etc.
-  `Hub` application

| Node | CPU | RAM | Disk |
| -------- | ------ | ------- | ------ |
| Auth | 4 | 16 | 60 Gb |

#### 3.2. Operating system
- Theoretically system will run on any operating system that supports docker containers
- We recommend to use one of this operating systems (tested for installation)
  - CentOS 7
  - CentOS 8
  - Ubuntu 20.04 or newer


## 4. Installation variants

#### 4.1.Single node

- Recommended for small teams / First look at the system
- All services running on one machine
- Trivial installation
- A bit harder to manage load and reliability

#### 4.2. Spreaded across couple of nodes

- Recommended for professionals and large-scale companies
- You can spread services on several nodes to manage load
- A bit more complex installation (docker-compose and network management experience required)


## 5. Distributives

#### 5.1. Hypha is a set of services:
- App Gateway
- BFF
- Core
- Dashboard
- Files Manager
- Resource Manager
- Task Manager
- Workflow Manager

#### 5.2. Hub is a separate application (backend and frontend) that manages users and authentication
#### 5.3. All docker images could be found in  https://hub.docker.com/repositories/mycesys
#### 5.4. Compose files and sample configuration are published  at: https://github.com/mycesys/hypha-installation 

## 6. External components
- PostgreSQL
- Nginx
- RabbitMQ
- Configuration

## 7. Configuration

####  7.1. Directories
| Path | Description | 
| ------ | ----------------- |
| `auth/user/avatars/` | place where avatars for all users are stored |
| `core/common/avatars/` | place where avatars for all other objects are stored |
| `files/data/` | place where all main data is stored (models, simulation results etc). Usually these files take a large amount of space |
| `oauth/keys/` | place for RSA keys used in OAuth2 authentication process |
| `ssh/keys/` | place for SSH-keys for all computational clusters |
| `pg_auth` | PostgreSQL data directory for authentication service (Hub) |
| `pg_core` | PostgreSQL data directory for core service |
| `pg_dashboard` | PostgreSQL data directory for dashboard service | 
| `pg_fm` | PostgreSQL data directory for files management service | 
| `pg_rm` | PostgreSQL data directory for resources management service |
| `pg_tm` | PostgreSQL data directory for tasks management service | 
| `pg_workflow` | PostgreSQL data directory for workflow management service. |

#### 7.2. Security keys

- Place the `hypha` - a private key that will used by system to access computational nodes  in `ssh/keys`(corresponding public key should stored in `authorized_keys` file on all computational nodes)
- Place the `oauth` (private) and `oauth.pub` (corresponding public) keys in `oauth/keys`. The keys must be generated using the RSA algorithm in PKCS8 format.

#### 7.3. Docker-compose `.env` file

- Sample env-file could be found at: `/allinone/dot.env.example`
- This file contains all necessary properties for services running in the containers

#### 7.4. Docker-compose yml file

- Volumes
  - Each container configuration has `volumes:` section
  - Use directories from `6.1` to setup volumes mapping
  - NOTE: all data stored only inside docker container will be lost after restart
- Ports
  - Each container configuration has `ports:` section
  - NOTE: If you make changes to ports mapping don't forget to make corresponding changes in nginx configuration (`7.8`, `8.9`)

#### 7.5. Nginx configuration

- SSL certificates for https support
- Routes for running services

## 8. Installation guide (on one host)
	
#### 8.1. Use predefined docker-compose files and scripts from https://github.com/mycesys/hypha-installation 
#### 8.2. To install all components on one host use `docker-compose` and scripts in `allinone` directory
#### 8.3. Preparing directories
- Use existing
- Create with `prepare-dirs.sh` (on Linux platform)
#### 8.4. Preparing security keys for OAuth
- Use existing
- Generate with `generate-oauth-keys.sh` (on Linux platform)
#### 8.5. Preparing SSH keys for computational nodes access
- Use existing
- Generate with `generate-ssh-keys.sh` (on Linux platform)
#### 8.6. Configure `.env` file for docker-compose
- Sample env-file could be found at: `/allinone/dot.env.example`
- Copy it to `/allinone/.env` file
- Redirect properties (used for authentication)

| Key=Value | Description | 
| ------ | ----------------- |
| `OAUTH_ISSUER_URL`=https://localhost:3001 | place here public address of your Hub instance (example: https://hub.yourdomain.com:3001) |
| `FRONTEND_BASE_URL`=https://localhost:3001 | place here public address of your Hub instance (example: https://hypha.yourdomain.com:3001) |
| `HUB_WEB_APP_BASE_URL`=https://localhost:3001 | place here public address of your Hub instance (example: https://hypha.yourdomain.com:3001) |
| `HYPHA_WEB_APP_BASE_URL`=https://localhost | place here public address of your Hypha frontend (example: https://hypha.yourdomain.com) | 
| `WEB_APP_REDIRECT_URL`=https://localhost/oauth/callback | place here public address of your Hypha frontend (keep oauth/callback in place) |

- Common properties

| Key=Value | Description | 
| ------ | ----------------- |
| `ADMIN_PASSWORD`=root  | default password for first user |
| `SSH_DEFAULT_KEY_PATH`=/ssh/keys/hypha | 
| `AUTH_SECRET`=xxxxxx  | strong password (randomly generated) with length no less than 32 characters | 
| `HYPHA_SECRET`=xxxxxx | strong password (randomly generated) with length no less than 32 characters |

- Hostnames and ports for all services (leave them in place for “all in one” deployment)
  - SERVICE_CORE_URL=http://core:8081/
  - SERVICE_FILES_URL=http://file-manager:8097/
  - SERVICE_BFF_URL=http://bff:8100/
  - SERVICE_WORKFLOW_URL=http://workflow:8082/
  - SERVICE_RESOURCE_URL=http://resource-manager:8096/
  - SERVICE_TASK_URL=http://task-manager:8095/
  - SERVICE_DASHBOARD_URL=http://dashboard:8083/
  - SERVICE_AUTH_URL=http://auth:8098/
- RabbitMQ properties
  - RABBITMQ_HOST=rabbitmq
  - RABBITMQ_PORT=5672
  - RABBITMQ_DEFAULT_USER=guest
  - RABBITMQ_DEFAULT_PASS=guest
- Components versions
  - CORE_VERSION=2023.1
  - FILE_MANAGER_VERSION=2023.1
  - APP_GATEWAY_VERSION=2023.1
  - AUTH_VERSION=2023.1
  - BFF_VERSION=2023.1
  - WORKFLOW_MANAGER_VERSION=2023.1
  - RESOURCE_MANAGER_VERSION=2023.1
  - TASK_MANAGER_VERSION=2023.1
  - DASHBOARD_VERSION=2023.1
  - HYPHA_FRONTEND_VERSION=2023.1
  - HUB_FRONTEND_VERSION=2023.1

#### 8.7. Docker-compose.yml configuration
- Volumes
  - Each container configuration has `volumes:` section
  - Use directories from `7.1` to setup volumes mapping
  - NOTE: all data stored only inside docker container will be lost after restart
- Ports
  - Each container configuration has `ports:` section
  - NOTE: If you make changes to ports mapping don't forget to make corresponding changes in nginx configuration (`7.8`, `8.9`)
	
#### 8.8. Nginx configuration for Hypha

- Sample configuration could be found in `allinone/nginx.hypha_frontend.example.con`
- Specify location for SSL certificate (required) by setting parameters:
  - `include <path to ssl options configuration file>;` 
  - `ssl_dhparam <path to DH key>;`
  - `ssl_certificate <path to SSL fullchain cert>;` 
  - `ssl_certificate_key <path to SSL private key>;`
- NOTE: all this paths are inside docker container (look at  volume configuration in `7.7`)

#### 8.9. Nginx configuration for Hub

- Sample configuration can be found in `nginx.hub_frontend.example.conf`
- Specify location for SSL certificate (required) by setting parameters:
  - `include <path to ssl options configuration file>;` 
  - `ssl_dhparam <path to DH key>;`
  - `ssl_certificate <path to SSL fullchain cert>;` 
  - `ssl_certificate_key <path to SSL private key>;`
- NOTE: all this paths are inside docker container (look at volume configuration in `7.7`)

#### 8.10 Running services

- Before start all services please walk through the following checklist:
- Check the nginx ports in the configurations for Hypha-frontend and myc-hub-frontend, the listen 443 default_server ssl directiv
- Check the paths to the SSL certificates in the configurations for Hypha-frontend and myc-hub-frontend
- Check that the volumes are correctly mapped in docker-compose.yml
- Check that the ports are correctly forwarded in docker-compose.yml for `hypha-ui` and `hub-ui`
- Check that the server names and ports are correct in .env (matching the ports in nginx, docker-compose.yml, and .env)
- In the directory with `docker-compose.yml run:
  - `docker-compose pull` 
  - `docker-compose up -d` (`-d` to run in daemon mode)
