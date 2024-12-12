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

read -p "Enter Prover ID: " prover_id
BASE_PROVER_ID=$prover_id

read -p "Enter number of nodes: " nodes_number
NUM_CONTAINERS=$nodes_number # Pass the number of containers as the first argument

# Create the docker-compose.yml file
echo "version: '3.9'" > docker-compose.yml
echo "services:" >> docker-compose.yml

# Loop to create container entries
for ((i=1; i<=NUM_CONTAINERS; i++))
do
  CONTAINER_NAME="${SERVICE_NAME}-${i}"

  cat <<EOL >> docker-compose.yml
  ${CONTAINER_NAME}:
    container_name: ${CONTAINER_NAME}
    build: .
    restart: unless-stopped
    stop_grace_period: 5m
    environment:
      - PROVER_ID=${BASE_PROVER_ID}

EOL
done

echo "docker-compose.yml has been generated with ${NUM_CONTAINERS} containers."

header "Starting Docker compose"
docker compose up -d
