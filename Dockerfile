FROM alpine:3.23.3

# Build time arguments
ARG RESOURCES_DIR="/resources" \
    WORKING_DIR="/workspace" \
    DEV_USER="dev"

# Copy all resource files into the image to be used by the bootstrapper
COPY ./resources/ /${RESOURCES_DIR}/

# Run a full configuration script
RUN sh -e /resources/bootstrap.sh

# Shell Init script which will be evaluated when an intereactive shell is loaded
ENV ENV="/etc/.shinit"

# Login as non-root user
USER ${DEV_USER}

# By default start in the /workspace directory
WORKDIR ${WORKING_DIR}

LABEL devcontainer.metadata="[{ \
  \"remoteUser\": \"${DEV_USER}\", \
  \"workspaceFolder\": \"${WORKING_DIR}\", \
  \"postCreateCommand\": \"direnv exec . sh\" \
}]"