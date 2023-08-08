#!/bin/bash
set -eu
cat <<EOT > .env
BASE_IMAGE="nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04"
COMPOSE_PROJECT_NAME="projectname-`whoami`"
USER=`whoami`
UID=`id -u`
GID=`id -g`
USER_PASSWD="user"
ROOT_PASSWD="root"
PYTHON_VERSION="3.9.17"
MEM="4g"
SSH_PORT="22"
Jupyter_PORT="8888"
HOST_PORT="23"
CONTAINER_PORT="22"
EOT

# do "docker compose config" and check
