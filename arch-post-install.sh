#!/usr/bin/env bash
# Run:
# curl -s https://raw.githubusercontent.com/konsou/arch-post-install/refs/heads/main/arch-post-install.sh | sudo bash

# exit on error
set -e

# Red
ERROR_COLOR="\e[1;91m"
# Green
HEADER_COLOR="\e[1;32m"
STYLE_RESET="\e[0m"


# A function to print text inside a fancy box
box() {
  msg="# $* #"
  edge=$(echo "$msg" | sed 's/./#/g')
  echo
  echo -e "${HEADER_COLOR}${edge}"
  echo -e "${HEADER_COLOR}${msg}"
  echo -e "${HEADER_COLOR}${edge}${STYLE_RESET}"
}

as_user() {
  sudo -u "${SUDO_USER}" "$@"
}


box "konso's arch post-install script"


if [ "$EUID" -ne 0 ] || [ -z "$SUDO_USER" ]; then
  echo
  echo -e "${ERROR_COLOR}Please run as a regular user with sudo${STYLE_RESET}"
  exit 1
fi


box "Upgrade packages"
pacman -Syu --noconfirm
box "Packages upgrade complete"

box "Install yay"
pacman -S --needed --noconfirm base-devel git
# Stop git complaining about default branch name
as_user git config --global init.defaultBranch main
yay_tmp=$(as_user mktemp --directory --tmpdir yay-install.XXXXXXXXXX)
as_user git clone https://aur.archlinux.org/yay.git "${yay_tmp}"
cd "${yay_tmp}"
source PKGBUILD && pacman -S --noconfirm --needed --asdeps "${makedepends[@]}" "${depends[@]}"
as_user makepkg --noconfirm
pacman -U --noconfirm ./yay-*-x86_64.pkg.tar.zst
box "yay install complete"

box "Install extra packages"
box "Generic utils"
yay -S --needed --noconfirm \
  arch-install-scripts \
  cronie \
  cups \
  cups-browsed \
  cups-pdf \
  cups-pl-helper \
  dkms \
  dolphin-plugins \
  dosfstools \
  dysk \
  exfat-utils \
  fastfetch \
  fish \
  flatpak \
  fuse2 \
  ghostscript \
  ghostty \
  grub-customizer \
  informant \
  iotop \
  jnettop \
  jq \
  man-db \
  moreutils \
  nano \
  ncdu \
  net-tools \
  partitionmanager \
  rclone \
  rsync \
  samba \
  smartmontools \
  snapper \
  tldr \
  tpm2-tools \
  unrar \
  yaml-language-server \
  zfs-dkms \
  zfs-auto-snapshot \
  zoxide

# Mark old informant news items as read
sudo informant read --all

box "GUI apps"
yay -S --needed --noconfirm \
  discord \
  bitwarden \
  brave-bin \
  firefox \
  inkscape \
  libreoffice-fresh \
  qbittorent \
  signal-desktop \
  vlc

box "Fonts"
yay -S --needed --noconfirm \
  gsfonts \
  noto-fonts-cjk \
  ttf-bitstream-vera \
  ttf-dejavu


box "Dev tools"
yay -S --needed --noconfirm \
  cuda \
  docker \
  docker-compose \
  nvm \
  jetbrains-toolbox

#  brother-mfc-j5620dw \
#  brscan-skey \
#  brscan4 \
#  system-config-printer \
#  gutenprint \
#  imagemagick \
#  protontricks \
#  snapd \
#  steam \
#  wine \
#  wine-mono \
#  winetricks \
box "Extra packages install complete"
