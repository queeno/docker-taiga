# docker-taiga

Dockerfile to automate your [Taiga](https://Taiga.io/) deployment.

This project was initially forked from [ipedrazas/taiga-docker](https://github.com/ipedrazas/taiga-docker)

## Why queeno/docker-taiga

- Single docker container for taiga-front and taiga-back.
- Use your own webserver to power Taiga.

queeno/docker-taiga exposes port 8000 and exports the following volumes: /taiga-front-dist, /taiga-back/static, /taiga-back/media.
You can use your own webserver (or existing reverse proxy!) to serve the frontend and/or proxy the API requests.

assets/nginx/taiga.conf contains a sample configuration for the nginx container. More information available at the bottom of this README. 

## One step deployment

```bash
assets/scripts/setup.sh
```

will deploy and run the postgres and taiga containers in one go.

- Script parameters:

  `POSTGRES_DIR` indicates the host location where the postgres files will reside.
  `API_NAME` indicates the taiga API server name or IP address. This should also include the relative TCP port (unless it's implied by the schema).
  `API_SCHEMA` indicates whether the API requests will be made via HTTP or HTTPS

  You can pass values via environment variables. If you do not, the following defaults will apply:

  ```bash
  POSTGRES_DIR='/data/postgres'
  API_NAME='localhost:8000'
  API_SCHEMA='http'
  ```

## Manual deployment

If you want to manually deploy your docker container or to build your own image, please read this section.

### Installation

- Pull the latest image from Docker Hub
  
  ```bash
  docker pull queeno/docker-taiga
  ```

- or build your own image locally:
  
  ```bash
  git clone https://github.com/queeno/docker-taiga.git
  cd docker-taiga
  docker build -t queeno/docker-taiga .
  ```

### Run taiga

- Run the postgres container:
  
  ```bash
  docker run -d --name postgres -v ${POSTGRES_DIR}:/var/lib/postgresql/data postgres
  ```

- Initialise the database:
  
  ```bash
  docker exec postgres sh -c "su postgres --command 'createuser -d -r -s taiga'"
  docker exec postgres sh -c "su postgres --command 'createdb -O taiga taiga'"
  ```

- Run taiga:
  
  ```bash
  docker run -d -p 8000:8000 --env API_NAME="${API_NAME}" --name taiga --link postgres:postgres queeno/docker-taiga
  docker exec taiga bash -c "sed -i 's/API_NAME/${API_NAME}/g' /taiga-front-dist/dist/js/conf.json"
  docker exec taiga bash -c "sed -i 's/API_SCHEMA/${API_SCHEMA}/g' /taiga-front-dist/dist/js/conf.json"
  ```

- Initalise the database:
  
  ```bash
  docker exec taiga bash regenerate.sh
  ```

### Optional: set-up your own nginx webserver

If you don't intend to deploy taiga behind a pre-existing webserver or reverse proxy, you can spin up an nginx docker container in one second:

#### HTTP

```bash
docker run --volumes-from taiga --link taiga --name nginx -v "$(pwd)"/assets/nginx/taiga.conf:/etc/nginx/conf.d/default.conf:ro -p 80:80 -d nginx
```

#### HTTPS

1. Generate a keypair on the host
 ```bash
 openssl genrsa -out /tmp/taiga.pem 2048
 ```
 
1. Generate a CSR
 ```bash
 openssl req -new -key /tmp/taiga.pem -out /tmp/taiga.csr
 ```
 
1. Send the csr to your CA for signing or self sign it:
 ```bash
 openssl x509 -req -days 365 -in /tmp/taiga.csr -signkey /tmp/taiga.pem -out /tmp/taiga.crt
 ```
 
1. Store the keypair in your host's keychain - for example on CentOS:
 ```bash
 mv /tmp/taiga.pem /etc/pki/tls/private/
 mv /tmp/taiga.crt /etc/pki/tls/certs/
 ```
 
1. Run the nginx container:
 ```bash
 docker run --volumes-from taiga --link taiga --name nginx -v /etc/pki/tls/certs/taiga.crt:/etc/ssl/cert.pem:ro -v /etc/pki/tls/private/taiga.key:/etc/ssl/cert.key:ro -v /opt/nginx/taiga_ssl.conf:/etc/nginx/conf.d/default.conf:ro -p 443:443 -d nginx
 ```
