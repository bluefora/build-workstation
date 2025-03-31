#!/bin/bash

# Swap to signed
if rpm-ostree status -b | grep ostree-unverified-registry; then
    # notify user that we are upgrading

    # Rebase to signed image
    SIGN_URI=$(rpm-ostree status -b | grep -A1 "BootedDeployment:" | grep -v "BootedDeployment" | sed -E 's/.+ostree-unverified-registry:(.+)/ostree-image-signed:docker:\/\/\1/')
    echo "Signing installation - This will take a while"
    plymouth display-message --text="Signing installation - This will take a while" || true
    # shellcheck disable=SC2086
    rpm-ostree rebase $SIGN_URI

    # Notify user that a reboot is necessary, maybe wait first for flatpak to finish!
fi

# remove flatpak remote
flatpak remotes | grep fedora
if [[ $? ]]; then
    flatpak remote-delete fedora --force
fi

rm /etc/bluefora.firstrun