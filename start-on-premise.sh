#!/bin/bash

set -eu

case "$(uname)" in
	Darwin)
		DOCKER_HOST_IP=$(ifconfig | awk '$1 ~ /^inet$/ && $2 !~ /^127\./ { print $2; exit; }')
		;;
	Linux)
		DOCKER_HOST_IP=host.docker.internal
		;;
	*)
		DOCKER_HOST_IP=$(ipconfig | awk -F: '$1 ~ /IP Address/ { gsub(/^[ \t]+/, "", $2); gsub(/[ \t]+$/, "", $2); print $2; exit; }')
		;;
esac


# ----------------------------------------------------------------- #
# Beginning of variables section                                    #
#                                                                   #
# Change the value of the following variables to fit your settings. #
# ----------------------------------------------------------------- #

# ------------------ #
# REQUIRED VARIABLES #
# ------------------ #

# The username for downloading the binaries
# --> Get it from https://app.upscope.io/settings/teams/_/on_prem
DOWNLOAD_USER=

# The password for downloading the binaries
# --> Get it from https://app.upscope.io/settings/teams/_/on_prem
DOWNLOAD_PASSWORD=

# Your team's license key
# --> Get it from https://app.upscope.io/settings/teams/_/on_prem
LICENSE_KEY=

# The base URL where this component will be mounted
# Example: https://acmetech.com/cobrowsing/
BASE_ENDPOINT=

# A 32 characters long SECRET(!) key used to sign internal tokens
SECRET_KEY=

# If you want Upscope on-premise to integrate with the cloud Visitor list, enter your
# BASE_ENDPOINT and SECRET_KEY here: https://app.upscope.io/settings/teams/_/on_prem


# ------------------ #
# DATABASE ENDPOINTS #
# ------------------ #

# MongoDB #
# ------- #

# Automatically run MongoDB inside the container:
MONGO_URI=mongodb://localhost:27017/upscope

# You already run MongoDB in the host machine:
# MONGO_URI=mongodb://$DOCKER_HOST_IP:27017/upscope

# You want to connect to MongoDB in another host:
# MONGO_URI=mongodb://USER:PASSWORD@MONGODB_HOST:MONGODB_PORT/UPSCOPE_DATABASE


# Redis #
# ----- #

# Automatically run Redis server inside the container:
REDIS_URI=redis://localhost:6379/0

# You already run Redis in the host machine:
# REDIS_URI=redis://$DOCKER_HOST_IP:6379/0

# You want to connect to Redis server in another host:
# REDIS_URI=redis://REDIS_HOST:REDIS_PORT/REDIS_DATABASE_NUMBER


# ------------------ #
# OPTIONAL VARIABLES #
# ------------------ #

# Fill this with the authentication API key for your on-premise REST API.
# Leave it empty to disable the REST API.
REST_KEY=

# URL to redirect requests to the BASE_ENDPOINT to.
HOMEPAGE=https://upscope.com/

# The name you want to give to the container
CONTAINER_NAME=upscope

# The port your server should listen on
PORT=5002

# URL watch links will be redirected to this for authentication.
# Leave empty to default to the Upscope cloud
AUTH_ENDPOINT=

#--------------------------#
# End of variables section #
#--------------------------#

for varname in DOWNLOAD_USER DOWNLOAD_PASSWORD LICENSE_KEY SECRET_KEY
do
	if [[ -z "${!varname}" ]]
	then
		echo "$varname is required" >&2
		exit 1
	fi
done

exec docker run --rm --name "$CONTAINER_NAME" \
	-e "AUTH_ENDPOINT=$AUTH_ENDPOINT" \
	-e "BASE_ENDPOINT=$BASE_ENDPOINT" \
	-e "LICENSE_KEY=$LICENSE_KEY" \
	-e "DOWNLOAD_USER=$DOWNLOAD_USER" \
	-e "DOWNLOAD_PASSWORD=$DOWNLOAD_PASSWORD" \
	-e "HOMEPAGE=$HOMEPAGE" \
	-e "MONGO_URI=$MONGO_URI" \
	-e "REDIS_URI=$REDIS_URI" \
	-e "REST_KEY=$REST_KEY" \
	-e "SECRET_KEY=$SECRET_KEY" \
	-p "$PORT:5002/tcp" \
	-it upscope/onpremise:latest
