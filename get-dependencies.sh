#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	pipewire-audio \
	pipewire-jack

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

echo "Getting app..."
echo "---------------------------------------------------------------"
case "$ARCH" in # they use AMD64 and ARM64 for the deb links
	x86_64)  deb_arch=amd64;;
	aarch64) deb_arch=arm64;;
esac
DEB_LINK=$(wget https://api.github.com/repos/FreeTubeApp/FreeTube/releases -O - \
      | sed 's/[()",{} ]/\n/g' | grep -o -m 1 "https.*$deb_arch.deb")
echo "$DEB_LINK" | awk -F'/' '{gsub(/^v/, "", $(NF-1)); print $(NF-1); exit}' > ~/version
if ! wget --retry-connrefused --tries=30 "$DEB_LINK" -O /tmp/app.deb 2>/tmp/download.log; then
	cat /tmp/download.log
	exit 1
fi

mkdir -p ./AppDir/bin
ar xvf /tmp/app.deb
tar -xvf ./data.tar.xz
rm -f ./*.xz
rm -rf ./usr/share/doc
mv -v ./opt/FreeTube/* ./AppDir/bin
mv -v ./usr/share/applications/freetube.desktop ./AppDir
