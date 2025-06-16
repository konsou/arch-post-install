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
