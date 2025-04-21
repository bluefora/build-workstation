#!/bin/bash

# Swap to signed
if rpm-ostree status -b | grep ostree-unverified-registry; then
    # notify user that we are upgrading

    # Rebase to signed image
    SIGN_URI=$(rpm-ostree status -b | grep -A1 "BootedDeployment:" | grep -v "BootedDeployment" | sed -E 's/.+ostree-unverified-registry:(.+)/ostree-image-signed:docker:\/\/\1/')
    echo "Signing installation - This will take a while"
    plymouth display-message --text="Signing installation - This will take a while" || true
    rpm-ostree rebase $SIGN_URI
fi

# remove flatpak remote
if flatpak remotes | grep fedora; then
    echo "Removing Fedora remote from flatpak"
    plymouth display-message --text="Removing Fedora remote" || true
    flatpak remote-delete fedora --force
fi


typeset APPS=(
	[org.gnome.Calculator]="Calculator"
	[org.gnome.Loupe]="Photos"
	[org.gnome.TextEditor]="Text Editor"
	[org.gnome.Totem]="Video Player"
	[org.mozilla.firefox]="Firefox"
	[flathub page.tesk.Refine]="Refine"
)
for app in "${!APPS[@]}"; do
    echo "Installing ${APPS[$app]}"
    plymouth display-message --text="Installing ${APPS[$app]}" || true
    flatpak install $app
done


rm -f /etc/bluefora.firstrun
systemctl reboot
