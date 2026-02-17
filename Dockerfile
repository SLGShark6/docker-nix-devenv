FROM alpine:3.23.3

ADD ./bootstrap.sh /tmp/

ENV NIX_CONFIG="experimental-features = nix-command flakes"

RUN sh -e /tmp/bootstrap.sh

ENV PATH="/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin:${PATH}"