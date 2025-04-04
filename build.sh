#!/bin/bash

set -ouex pipefail

# Update release file
sed -i -e "s/ID=silverblue/ID=${BUILD_ID:=unknown}/g" /usr/lib/os-release
sed -i -e "s/Silverblue/${OS_NAME:=Bluefora}/g" /usr/lib/os-release
sed -i -e "s/Fedora Linux 41 (Workstation Edition)/$OS_NAME Linux 41 (${BUILD_NAME:=Unkown} Edition)/g" /usr/lib/os-release
sed -i -e "s/DEFAULT_HOSTNAME="fedora"/DEFAULT_HOSTNAME="${OS_ID:=bluefora}"/g" /usr/lib/os-release

rpm-ostree ex rebuild

# Cleanup
dnf5 -y remove \
    firefox \
    firefox-langpacks \
    f41-backgrounds-gnome \
    desktop-backgrounds-gnome \
    gnome-backgrounds-extras \
    gnome-backgrounds \
    nvtop htop

files=(flight futurecity glasscurtains mermaid montclair petals)
for file in "${files[@]}"; do
    rm /usr/share/gnome-background-properties/${file}.xml
done

# Set timezone
ln -s /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime


# Install Apps and Extensions
dnf5 -y install gnome-tweaks gnome-extensions-app \
            gnome-shell-extension-appindicator \
            gnome-shell-extension-blur-my-shell \
            gnome-shell-extension-caffeine \
            gnome-shell-extension-dash-to-panel \
            gnome-shell-extension-just-perfection

# Disable welcome screen
cat > /etc/dconf/db/local.d/00-disable-gnome-tour <<EOF
[org/gnome/shell]
welcome-dialog-last-shown-version='$(rpm -qv gnome-shell | cut -d- -f3)'
EOF


# Install the modules
typeset MODULES=(quicksetup wallpapers wallpaper-cycler)
[[ -v EXTRA_MODULES ]] && MODULES=("${MODULES[@]}" "${EXTRA_MODULES[@]}")

for module in "${MODULES[@]}"; do
    # Clone the repo and copy the files
    git clone https://github.com/bluefora/${module} /tmp/${module}
    rsync -av --keep-dirlinks /tmp/${module}/rootcopy/* /

    # Try run the build script
    if [[ -f /tmp/${module}/build.sh ]]; thent
        bash /tmp/${module}/build.sh
    fi
done


# Update dconf
dconf update

# Install codecs
dnf5 -y swap ffmpeg-free ffmpeg --allowerasing


# Cleanup unused packages
dnf5 -y remove nvtop htop
