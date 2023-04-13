## Introduction

- Website: https://mycesys.com
- What is Hypha:

Hypha is a SPDM system that allows to manage data and simulations, run computational tasks and process the results. First enterprise level system available for teams up to 5 users for free.

- User guide: https://mycesys.com/hypha/2023.1/userguide.pdf
- Installation guide: https://github.com/mycesys/hypha-installation
- Docker images: https://hub.docker.com/repositories/mycesys

## Installation

### Table of content

1. Requirements
2. Configuration
 - Architecture
 - Configuration
 - Run Hypha & Hub
3. Advanced guide
-  Generate and use self-signed SSL certificate
-  Install Hypha on several nodes
4. Troubleshooting

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
- `openssl`

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
| `ssl/` | place for SSL certificates for HTTPS support |
| `pg_auth` | PostgreSQL data directory for authentication service (Hub) |
| `pg_core` | PostgreSQL data directory for core service |
| `pg_dashboard` | PostgreSQL data directory for dashboard service |
| `pg_fm` | PostgreSQL data directory for files management service |
| `pg_rm` | PostgreSQL data directory for resources management service |
| `pg_tm` | PostgreSQL data directory for tasks management service |
| `pg_workflow` | PostgreSQL data directory for workflow management service |
| `rabbitmq_data` | RabbitMQ directory for persistent data |

##### Configure certificates and keys

- OAuth
  - Place the `oauth` (private) and `oauth.pub` (corresponding public) keys in `oauth/keys`. The keys must be generated using the RSA algorithm in PKCS8 format
  - To generate new keys run `./generate-oauth-keys.sh`
- SSH
  - Place the `hypha` - a private key that will used by system to access computational nodes  in `ssh/keys`(corresponding public key should stored in `authorized_keys` file on all computational nodes)
  - To generate new keys run `./generate-ssh-keys.sh`
- SSL
  - Place SSL certificate files into `./ssl` dir

  | File | Description |
  | ------ | ----------------- |
  | `ssl-dhparams.pem` | Diffie-Hellman group |
  | `fullchain.pem` |SSL certificate |
  | `privkey.pem` | SSL private key |
  | `options-ssl-nginx.conf` | SSL configuration file (decribed below) |
 
   - `options-ssl-nginx.conf` could be found in `selfsigned/` (if you don't have one from SSL certificate provider)
  - To generate self-signed SSL certificate follow the instructions at chapter `3. Advanced guide` of this guide

##### Configure `.env` file

- Copy sample env file to `.env` : `cp ./dot.env.example ./.env`
- Required changes in `.env`
  - Redirect URLs

  | Key=Value | Description |
  | ------ | ----------------- |
	| `HUB_PUBLIC_PORT=8301` | port for HUB interface URL |
  | `HYPHA_PUBLIC_PORT=8300` | port for HYPHA interface URL |
  | `OAUTH_ISSUER_URL=https://<HUB_DOMAIN>:${HUB_PUBLIC_PORT}` | place here public address of your Hub instance |
  |`FRONTEND_BASE_URL=https://<HUB_DOMAIN>:${HUB_PUBLIC_PORT}` | place here public address of your Hub instance |
  | `HUB_WEB_APP_BASE_URL=https://<HUB_DOMAIN>:${HUB_PUBLIC_PORT}` | place here public address of your Hub instance |
  | `HYPHA_WEB_APP_BASE_URL=https://<HYPHA_DOMAIN>:${HYPHA_PUBLIC_PORT}` | place here public address of your Hypha frontend |
  | `WEB_APP_REDIRECT_URL=https://<HYPHA_DOMAIN>:${HYPHA_PUBLIC_PORT}/oauth/callback` | place here public address of your Hypha frontend (keep `oauth/callback` in place) |
	
  - Secrets

  | Key=Value | Description |
  | ------ | ----------------- |
  | `ADMIN_PASSWORD`=root  | default password for firsts user: `admin@mycesys.com` |
  | `AUTH_SECRET`=xxxxxx  | strong password (randomly generated) with length no less than 32 characters |
  | `HYPHA_SECRET`=xxxxxx | strong password (randomly generated) with length no less than 32 characters |

  - All other changes in `.env` are optional for allinone setup

**For all-in-one installation <HYPHA_DOMAIN> and <HUB_DOMAIN> are the same. Use different ports.**

#### Run Hypha & Hub

In the `allinone` direcotry run:

- `docker-compose pull`
- `docker-compose up -d` (`-d` to run in daemon mode)

### 3. Advanced guide

#### Generate and use self-signed SSL certificate

You can obtain SSL certificate for your DNS record or IP address and use it to secure network conenctions for free without CA (certificate authority).

**Advantages**
- Free long term SSL certificate
- Easy to manage (create, change, prolongate)
- No dependencies on CA

**Disadvantages**
- Browser will ask for confirmation
- Additional steps in installation process required

**How to obtain the certificate:**

- All actions should be performed in `allinone` directory
- Copy `selfsigned/v3.ext` and `selfsigned/ssl.cnf` to `ssl/`
	- `cp selfsigned/ssl.cnf ssl/` - Contains basic SSL paramaters
  - `cp selfsigned/v3.ext ssl/` - Contains SAN parametes
- Fill `ssl/ssl.cnf` with your server parameters
	- `C = US` - country code 
	- `ST = State` - state
	- `L = City` - your city
	- `O = Org LLC` - your organization
	- `OU = Org Unit` - your organization unit
	- `CN = example.com` - Common Name: set your server FQDN or IP address here
- Fill `ssl/v3.ext` with your server parameters
  - `subjectAltName = IP:value,DNS:value` - place comma separated pairs `IP:<ip address>` or `DNS:<DNS name>` corresponding to your server
- Run `./generate-ssl-keys.sh` - process might take some time to generate keys
- Now you have self signed certificate for 10 years with SAN block

**Additional steps required after running all containers. Add certificate to `hub-auth` and `hypha-gateway` JKS keystores in JDK**

  - run `docker exec -it hub-auth /bin/bash`
  - run `cd /ssl`
  - run `keytool -importkeystore -srckeystore ./identity.p12 -srcstoretype PKCS12 -srcstorepass mycesys -destkeystore $JAVA_HOME/lib/security/cacerts -deststoretype JKS -deststorepass changeit` (set correct `-srcstorepass` if you changed it in `generate-ssl-keys.sh`)
  - run `exit`
  - run `docker exec -it hypha-gateway /bin/bash`
  - run `cd /ssl`
  - run `keytool -importkeystore -srckeystore ./store.p12 -srcstoretype PKCS12 -srcstorepass mycesys -destkeystore $JAVA_HOME/lib/security/cacerts -deststoretype JKS -deststorepass changeit` (set correct `-srcstorepass` if you change it in `generate-ssl-keys.sh`)
  - run `exit`
  - run `docker restart hub-auth hypha-gateway`

#### Install Hypha on several nodes

**TBD**

### 4. Troubleshooting

**TBD**
