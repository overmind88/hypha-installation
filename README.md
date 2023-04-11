## Introduction

- Website: https://mycesys.com
- What is Hypha:

Hypha is a SPDM system that allows to manage data and simulations, run computational tasks and process the results. First enterprise level system available for teams up to 5 users for free. 

- Link to user guide: [Hypha & Hub User Guide](https://mycesys.com/hypha/2023.1/userguide.pdf)
- Installation guide: https://github.com/mycesys/hypha-installation
- Docker images: https://hub.docker.com/repositories/mycesys

## Installation

### Table of content

1. Requirements
2. Configuration
 - Architecture
 - Configuration
 - Run Hypha & Hub

### 1. Requrements

#### Hardware

- Minimal

| Node | CPU | RAM | Disk |
| -------- | ------ | ------- | ------ |
| All in one + Hub | 8 | 24 | 512 Gb |

- Optimal

| Node | CPU | RAM | Disk |
| -------- | ------ | ------- | ------ |
| All in one | 16 | 64 | 512 Gb |
| Hub | 4 | 6 | 60 Gb |

- Enterprise

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

#### Software

- `docker`
- `docker-compose`
- `openssl` - https://www.openssl.org/

#### Host & Network

- Internet access to [Docker Hub](https://hub.docker.com)
- Priviledges to run docker containers
- SSL certificate (HTTPS required to support OAuth and native hashing algorithm)
	- If you don't have one you can get it for free from https://letsencrypt.org/ or use self-signed

#### Operating system
- Theoretically system will run on any operating system that supports docker containers
- We recommend to use one of this operating systems (tested for installation)
  - CentOS 7
  - CentOS 8
  - Ubuntu 20.04 or newer

### 2. Installation (All in one)

####  Architecture

![All in one installation scheme](https://mycesys.com/hypha/2023.1/hypha-hub_allinone_scheme.png)

#### Configuration

- Docker images at Docker Hub: https://hub.docker.com/repositories/mycesys
- Sample configuration & scripts: https://github.com/mycesys/hypha-installation 

**NEXT STEPS SHOULD BE EXECUTED IN `allinone` direcotry**

##### Prepare directories

- Run `./prepare-dirs.sh`
- Following directories will be created

| Path | Description | 
| ------ | ----------------- |
| `auth/user/avatars/` | place where avatars for all users are stored |
| `core/common/avatars/` | place where avatars for all other objects are stored |
| `files/data/` | place where all main data is stored (models, simulation results etc). Usually these files take a large amount of space |
| `oauth/keys/` | place for RSA keys used in OAuth2 authentication process |
| `ssh/keys/` | place for SSH-keys for all computational clusters |
| `ssl/` | place SSL certificates for HTTPS support |
| `pg_auth` | PostgreSQL data directory for authentication service (Hub) |
| `pg_core` | PostgreSQL data directory for core service |
| `pg_dashboard` | PostgreSQL data directory for dashboard service | 
| `pg_fm` | PostgreSQL data directory for files management service | 
| `pg_rm` | PostgreSQL data directory for resources management service |
| `pg_tm` | PostgreSQL data directory for tasks management service | 
| `pg_workflow` | PostgreSQL data directory for workflow management service |
| `rabbitmq_data` | RabbitMQ data directory for persistent data |

##### Configure certificates and keys

- OAuth
		- Place the `oauth` (private) and `oauth.pub` (corresponding public) keys in `oauth/keys`. The keys must be generated using the RSA algorithm in PKCS8 format
		- To generate this keys run `./generate-oauth-keys.sh`
- SSH
	- Place the `hypha` - a private key that will used by system to access computational nodes  in `ssh/keys`(corresponding public key should stored in `authorized_keys` file on all computational nodes)
	- To generate this keys run `./generate-ssh-keys.sh`
- SSL
	- Place SSL certificate files into `./ssl` dir

  | File | Description | 
  | ------ | ----------------- |
  | `ssl-dhparams.pem` | Diffie-Hellman group |
  | `fullchain.pem` |SSL certificate |
  | `privkey.pem` | SSL private key |
  | `options-ssl-nginx.conf` | SSL configuration file (decribed below) |
	
	- `options-ssl-nginx.conf` - snippet of nginx parameters for SSL. In minimal configuration you can use these values:

```
ssl_session_cache shared:le_nginx_SSL:10m;
ssl_session_timeout 1440m;
ssl_session_tickets off;

ssl_protocols TLSv1.2 TLSv1.3;
ssl_prefer_server_ciphers off;

ssl_ciphers "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384";
```

- To generate self-signed SSL certificate run './generate-ssl-keys.sh'

##### Configure `.env` file

- Copy sample env file to `.env` : `cp ./dot.env.example ./.env`
- Required changes in `.env`
  - Redirect URLs

  | Key=Value | Description | 
  | ------ | ----------------- |
  | `OAUTH_ISSUER_URL`=https://localhost:3001 | place here public address of your Hub instance (example: https://hub.yourdomain.com:3001) |
  | `FRONTEND_BASE_URL`=https://localhost:3001 | place here public address of your Hub instance (example: https://hypha.yourdomain.com:3001) |
  | `HUB_WEB_APP_BASE_URL`=https://localhost:3001 | place here public address of your Hub instance (example: https://hypha.yourdomain.com:3001) |
  | `HYPHA_WEB_APP_BASE_URL`=https://localhost | place here public address of your Hypha frontend (example: https://hypha.yourdomain.com) | 
  | `WEB_APP_REDIRECT_URL`=https://localhost/oauth/callback | place here public address of your Hypha frontend (keep oauth/callback in place) |
  
  - Secrets
  
  | Key=Value | Description | 
  | ------ | ----------------- |
  | `ADMIN_PASSWORD`=root  | default password for first user |
  | `AUTH_SECRET`=xxxxxx  | strong password (randomly generated) with length no less than 32 characters | 
  | `HYPHA_SECRET`=xxxxxx | strong password (randomly generated) with length no less than 32 characters |
  | `RABBITMQ_DEFAULT_USER`=guest | default user for RabbitMQ |
  | `RABBITMQ_DEFAULT_PASS`=guest | default pass for default RabbitMQ user |

  - All other changes in `.env` are optional for allinone setup

#### Run Hypha & Hub

In the `allinone` direcotry run:

- `docker-compose pull` 
- `docker-compose up -d` (`-d` to run in daemon mode)
