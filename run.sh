#!/bin/bash

DEBUG=false

# Check for --debug parameter
for arg in "$@"; do
  if [ "$arg" == "--debug" ]; then
    DEBUG=true
    # Remove --debug from arguments
    set -- "${@/--debug/}"
  fi
done

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <command> --profiles <profile_list> [--debug]"
  echo "Commands: build, up, up --build, down"
  exit 1
fi

COMMAND=$1
shift

COMPOSE_FILES="-f docker-compose.yml"
PROFILES=()

# Set default ENV if not provided
if [ -z "$ENV" ]; then
  ENV=dev
fi

# Extract profiles from arguments
while (( "$#" )); do
  case "$1" in
    --profiles)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        IFS=',' read -r -a PROFILES <<< "$2"
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    *)
      shift
      ;;
  esac
done

# Set PROFILE environment variable
export PROFILE=$(IFS=','; echo "${PROFILES[*]}")

# Include profiles in the compose files
for profile in "${PROFILES[@]}"; do
  COMPOSE_FILES="$COMPOSE_FILES -f ../selfhost-${profile}/docker-compose.yml"
  echo "Adding profile: $profile"

  # Export environment variables from profile-specific .env files
  PROFILE_ENV_FILE="../selfhost-${profile}/.env.${ENV}"
  if [ -f "$PROFILE_ENV_FILE" ]; then
    set -o allexport
    source $PROFILE_ENV_FILE
    set +o allexport

    # Dynamically substitute environment variables in the profile-specific .env file and append to the temporary .env file
    envsubst < $PROFILE_ENV_FILE >> .env.temp
  else
    echo "Warning: Environment file $PROFILE_ENV_FILE not found. Skipping."
  fi
done

# Check if the base .env file exists
if [ ! -f .env ]; then
  echo "Error: .env file not found in the root directory."
  exit 1
fi

# Load environment variables from the base .env file
set -o allexport
source .env
set +o allexport

# Dynamically substitute environment variables in the .env file and create a temporary .env file
envsubst < .env > .env.temp

# Ensure PROFILE is included in the temporary .env file
echo "PROFILE=${PROFILE}" >> .env.temp

if [ "$DEBUG" = true ]; then
  # Print environment variables for debugging
  echo "=============="
  echo "Environment variables after loading all .env files:"
  env | grep -E 'LLM_PORT|IMAGE_PORT|SPEECH_PORT|VIDEO_PORT|REDIS_PORT|SSL_CERTIFICATE|SSL_CERTIFICATE_KEY|UPSTREAM_LLM|UPSTREAM_IMAGE|UPSTREAM_VIDEO|UPSTREAM_SPEECH|PROFILE'

  # Print the content of the temporary .env file for debugging
  echo "=============="
  echo "Content of .env.temp:"
  cat .env.temp
fi

# Construct the profile string for the docker-compose command
PROFILE_ARGS=""
for profile in "${PROFILES[@]}"; do
  PROFILE_ARGS="$PROFILE_ARGS --profile $profile"
done

# Determine the docker-compose command based on the input
case $COMMAND in
  build)
    [ "$DEBUG" = true ] && echo "=============="
    [ "$DEBUG" = true ] && echo "Running: docker-compose --env-file .env.temp $COMPOSE_FILES $PROFILE_ARGS build" && echo
    docker-compose --env-file .env.temp $COMPOSE_FILES $PROFILE_ARGS build
    ;;
  up)
    [ "$DEBUG" = true ] && echo "=============="
    [ "$DEBUG" = true ] && echo "Running: docker-compose --env-file .env.temp $COMPOSE_FILES $PROFILE_ARGS up" && echo
    docker-compose --env-file .env.temp $COMPOSE_FILES $PROFILE_ARGS up
    ;;
  "up --build")
    [ "$DEBUG" = true ] && echo "=============="
    [ "$DEBUG" = true ] && echo "Running: docker-compose --env-file .env.temp $COMPOSE_FILES $PROFILE_ARGS up --build" && echo
    docker-compose --env-file .env.temp $COMPOSE_FILES $PROFILE_ARGS up --build
    ;;
  down)
    [ "$DEBUG" = true ] && echo "=============="
    [ "$DEBUG" = true ] && echo "Running: docker-compose --env-file .env.temp $COMPOSE_FILES $PROFILE_ARGS down" && echo
    docker-compose --env-file .env.temp $COMPOSE_FILES $PROFILE_ARGS down
    ;;
  *)
    echo "Invalid command: $COMMAND"
    echo "Commands: build, up, up --build, down"
    exit 1
    ;;
esac

# Clean up the temporary .env file
rm .env.temp