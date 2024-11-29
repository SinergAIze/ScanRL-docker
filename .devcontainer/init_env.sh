#!/usr/bin/env sh

## This script's purpose is to dump information about the localhost user such
## that it may be ingested by the .Dockerfile in this directory, to create a
## container with the user's settings.

# Set script running options
# -e: Exit on error. (from above)
# -u: Error on unbound var.
# -x: Debug mode, echoes commands before they're executed.
set -eux

# User name is passed as a build argument, see `devcontainer.json`
echo "USER_UID=$(id -u $USER)" > .devcontainer/.env
echo "GROUPNAME=$(id -gn $USER)" >> .devcontainer/.env
echo "GROUP_GID=$(id -g $USER)" >> .devcontainer/.env

# Unset script options.
set +eux
