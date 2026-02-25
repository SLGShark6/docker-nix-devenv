FROM alpine:3.23.3

# Cross script environment variables
ENV DEV_USER="dev" \
    PATH="/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin:$PATH" \
    NIX_CONFIG="experimental-features = nix-command flakes"

# Named directory paths
ENV RESOURCES_DIR="/resources" \
    WORKING_DIR="/workspace"

# Names of resource files passed into the image
ENV CONFIGURATION_SCRIPT_FILE="bootstrap.sh" \
    STARTUP_SCRIPT_FILE="entrypoint.sh" \
    SHELL_INIT_FILE=".shinit" \
    NIX_CONFIG_FILE="nix.conf"

# Final resting place of included resource files
ENV CONFIGURATION_SCRIPT_PATH="${RESOURCES_DIR}/${CONFIGURATION_SCRIPT_FILE}" \ 
    STARTUP_SCRIPT_PATH="${RESOURCES_DIR}/${STARTUP_SCRIPT_FILE}" \
    SHELL_INIT_PATH="/etc/${SHELL_INIT_FILE}" \
    NIX_CONFIG_PATH="/etc/nix/${NIX_CONFIG_FILE}"

# Copy all resource files into the image to be used by the bootstrapper
COPY ./resources/ ${RESOURCES_DIR}/

# Run a full configuration script
RUN sh -e ${CONFIGURATION_SCRIPT_PATH}

# Shell Init script which will be evaluated when an intereactive shell is loaded
ENV ENV="${SHELL_INIT_PATH}"

# Login as non-root user
USER ${DEV_USER}

# By default start in the /workspace directory
WORKDIR ${WORKING_DIR}

# Default Script executed at startup (can be overridden)
ENTRYPOINT ["/resources/entrypoint.sh"]

# Dev container configuration
LABEL devcontainer.metadata="[{ \
  \"remoteUser\": \"${DEV_USER}\", \
  \"workspaceFolder\": \"${WORKING_DIR}\", \
}]"