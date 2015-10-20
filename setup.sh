#! /usr/bin/env bash

POSTGRES_DIR='/data/postgres'

if [[ $OSTYPE != darwin* ]]; then
  SUDO=sudo
fi

if [[ -z "$API_NAME" ]]; then
    API_NAME="localhost";
fi

[[ -d ${POSTGRES_DIR} ]] && sudo mkdir -p ${POSTGRES_DIR}

$SUDO docker pull queeno/taiga

# Run Postgres
$SUDO docker run -d --name postgres -v ${POSTGRES_DIR}:/var/lib/postgresql/data postgres

# Postgres needs some time to startup
sleep 5

# Initialise the database
docker exec postgres sh -c "su postgres --command 'createuser -d -r -s taiga'"
docker exec postgres sh -c "su postgres --command 'createdb -O taiga taiga'"

# Run taiga
docker run -d -p 8000:8000 --env API_NAME="${API_NAME}" --name taiga --link postgres:postgres queeno/taiga
docker exec taiga bash -c "sed -i 's/API_NAME/${API_NAME}/g' /taiga-front-dist/dist/js/conf.json"

# Populate the database
docker exec taiga bash regenerate.sh
