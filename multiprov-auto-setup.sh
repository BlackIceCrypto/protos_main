#!/bin/bash

BASE="https://raw.githubusercontent.com/BlackIceValidator/BlackIceGuides/refs/heads/main/base.sh"
source <(curl -s $BASE)
bold=$(tput bold)
normal=$(tput sgr0)

logo

header "Installing requirements"
system_update
install_requirements
remoove_old_docker
install_docker

# Script to generate a docker-compose.yml file with multiple containers

# Parameters
SERVICE_NAME="nexus-xyz-cli"

# Create the docker-compose.yml file
echo "version: '3.9'" > docker-compose.yml
echo "services:" >> docker-compose.yml

# Loop to create container entries
cat provers.env | while read BASE_PROVER_ID; do
  i=1
  CONTAINER_NAME="${SERVICE_NAME}-${BASE_PROVER_ID}-${i}"

  cat <<EOL >> docker-compose.yml
  ${SERVICE_NAME}:
    container_name: ${CONTAINER_NAME}
    build: .
    restart: unless-stopped
    stop_grace_period: 5m
    environment:
      - PROVER_ID=${BASE_PROVER_ID}

EOL

i=$(( $i + 1 ))
done

echo "docker-compose.yml has been generated with ${i} containers."

header "Starting Docker compose"
docker compose up -d
