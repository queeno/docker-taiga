#! /usr/bin/env bash

[[ -z "${POSTGRES_DIR}" ]] && POSTGRES_DIR='/data/postgres'
[[ -z "${API_NAME}" ]] && API_NAME="localhost:8000"
[[ -z "${API_SCHEMA}" ]] && API_SCHEMA="http"
[[ $OSTYPE != darwin* ]] && SUDO=sudo

[[ -d ${POSTGRES_DIR} ]] && sudo mkdir -p ${POSTGRES_DIR}

$SUDO docker pull queeno/docker-taiga

# Run Postgres
$SUDO docker run -d --name postgres -v ${POSTGRES_DIR}:/var/lib/postgresql/data postgres

# Postgres needs some time to startup
sleep 10

# Initialise the database
$SUDO docker exec postgres sh -c "su postgres --command 'createuser -d -r -s taiga'"
$SUDO docker exec postgres sh -c "su postgres --command 'createdb -O taiga taiga'"

# Run taiga
$SUDO docker run -d -p 8000:8000 --env API_NAME="${API_NAME}" --name taiga --link postgres:postgres queeno/docker-taiga
$SUDO docker exec taiga bash -c "sed -i 's/API_NAME/${API_NAME}/g' /taiga-front-dist/dist/js/conf.json"
$SUDO docker exec taiga bash -c "sed -i 's/API_SCHEMA/${API_SCHEMA}/g' /taiga-front-dist/dist/js/conf.json"

# Populate the database
$SUDO docker exec taiga bash regenerate.sh
