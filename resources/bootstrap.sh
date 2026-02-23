#! /bin/sh -e

# Move the shell initializer into place
mv /$RESOURCES_DIR/.shinit /etc/.shinit
# Evaluate the shell init so everything is available going forward
source /etc/.shinit

# Install Nix Package Manager, with latest all hookups should happen
# automatically
apk --no-cache add nix
# Overwrite the default config with the one contained in the resources
mv /$RESOURCES_DIR/nix.conf /etc/nix/nix.conf

# Using nix install devenv and direnv
nix profile add \
    nixpkgs#devenv \
    nixpkgs#direnv \
    --profile /nix/var/nix/profiles/default

# Add a non-root group & user
addgroup -S $DEV_USER
adduser -S $DEV_USER -G $DEV_USER
# Ensure the user is a part of the users that can use nix
addgroup $DEV_USER nix

# Get the DEV_USER home directory
dev_home=$(getent passwd $DEV_USER | cut -d: -f6)

# Make a workspace directory to copy a project to
mkdir ${WORKING_DIR}
chown $DEV_USER:$DEV_USER ${WORKING_DIR}

# DEV_USER direnv config file destination
direnv_config_dir=$dev_home/.config/direnv
# Ensure direnv config directory is created
mkdir -p $direnv_config_dir
# Move the direnv config to whitelist the /workspace directory by default
mv /$RESOURCES_DIR/direnv.toml $direnv_config_dir/direnv.toml
# Ensure that the file is owned by the DEV_USER
chown -R $DEV_USER:$DEV_USER $dev_home

# Cleanup files and caches
nix-collect-garbage -d
rm -rf /root/.cache/nix/*

# Make the dev user the final owner of nix (otherwise they wont be able to run 
# commands). This is necessary as there is no way to easily get the the nix
# daemon running in the alpine container to enable multi-user nix, so we have
# to run in single-user mode
chown -R $DEV_USER:$DEV_USER /nix
# Ensure the nix config is also editable by the dev user
chown $DEV_USER:$DEV_USER /etc/nix/nix.conf

# Finally remove any remaining resources
rm -rf /$RESOURCES_DIR