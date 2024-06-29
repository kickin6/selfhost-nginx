#!/bin/bash

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <command> <profile> [additional_profiles...]"
  echo "Commands: build, up, up --build"
  exit 1
fi

COMMAND=$1
shift

COMPOSE_FILES="-f docker-compose.yml"

for profile in "$@"; do
  COMPOSE_FILES="$COMPOSE_FILES -f docker-compose.$profile.yml"
done

# Set default ENV if not provided
if [ -z "$ENV" ]; then
  ENV=dev
fi

# Check if the base .env file exists
if [ ! -f .env ]; then
  echo "Error: .env file not found in the root directory."
  exit 1
fi

# Export environment variables from the base .env file
export $(grep -v '^#' .env | xargs)

# Export environment variables from profile-specific .env files
for profile in "$@"; do
  PROFILE_ENV_FILE="../selfhost-${profile}/.env.${ENV}"
  if [ -f "$PROFILE_ENV_FILE" ]; then
    export $(grep -v '^#' $PROFILE_ENV_FILE | xargs)
  else
    echo "Warning: Environment file $PROFILE_ENV_FILE not found. Skipping."
  fi
done

# Determine the docker-compose command based on the input
case $COMMAND in
  build)
    docker-compose $COMPOSE_FILES build
    ;;
  up)
    docker-compose $COMPOSE_FILES up
    ;;
  "up --build")
    docker-compose $COMPOSE_FILES up --build
    ;;
  *)
    echo "Invalid command: $COMMAND"
    echo "Commands: build, up, up --build"
    exit 1
    ;;
esac
