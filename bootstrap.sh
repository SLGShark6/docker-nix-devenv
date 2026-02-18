#! /bin/sh -e

# Install Nix Package Manager, with latest all hookups should happen
# automatically
apk --no-cache add nix

# Using nix install devenv and direnv
nix profile add \
    nixpkgs#devenv \
    nixpkgs#direnv \
    --profile /nix/var/nix/profiles/default

# Cleanup files and caches
nix-collect-garbage -d
rm /tmp/bootstrap.sh
rm -rf /root/.cache/nix/*