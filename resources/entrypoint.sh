#! /bin/sh -e

# Load the environment
source $ENV

# Execute direnv
direnv allow $(pwd)
eval "$(direnv export bash)" # Also makes bash available

# Passthrough any passed CMD
exec "$@"