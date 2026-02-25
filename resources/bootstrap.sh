#! /bin/sh -e

# Move the shell initializer into place
mv $RESOURCES_DIR/.shinit /etc/.shinit
# Evaluate the shell init so everything is available going forward
source /etc/.shinit

# Install Nix Package Manager, with latest all hookups should happen
# automatically
apk --no-cache add nix
# Overwrite the default config with the one contained in the resources
mv $RESOURCES_DIR/nix.conf /etc/nix/nix.conf

# Using nix install devenv and direnv
nix profile add \
    nixpkgs#devenv \
    nixpkgs#direnv \
    --profile /nix/var/nix/profiles/default

# Add a non-root group & user
addgroup $DEV_USER
adduser $DEV_USER --disabled-password -G $DEV_USER
# Ensure the user is a part of the users that can use nix
addgroup $DEV_USER nix

# Make a workspace directory to copy a project to
mkdir $WORKING_DIR
chown $DEV_USER:$DEV_USER $WORKING_DIR

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

# Ensure the default startup command is owned and executable
chown $DEV_USER:$DEV_USER $STARTUP_SCRIPT
chmod +x $STARTUP_SCRIPT

# Finally remove this script from resources
rm -rf $RESOURCES_DIR/bootstrap.sh