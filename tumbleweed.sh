#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "You must be root to do this." 1>&2
   exit 1
fi

if [[ -z "$1" ]]; then
    echo "No target directory supplied."
    exit 2
fi

if [[ -z "$2" ]]; then
    echo "No target hostname supplied."
    exit 2
fi

target=$(realpath $1)

if [[ -d $target/dev ]]; then
    echo "Target directory already contains either a partial or full installation: $target"
	echo "Sleeping for 10 seconds... Press Ctrl+C to abort execution."
	sleep 10
fi

mkdir -p $target/dev
mkdir -p $target/sys
mkdir -p $target/proc
mount -t devtmpfs devtmpfs $target/dev
mount -t devpts devpts $target/dev/pts
mount -t sysfs sysfs $target/sys
mount -t proc proc $target/proc

echo "Enabling repositories"
zypper -R $target addrepo --refresh -p 90 "https://download.nvidia.com/opensuse/tumbleweed" "nvidia"
zypper -R $target addrepo --refresh -p 90 "http://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed" "packman"
zypper -R $target addrepo --refresh --disable "http://download.opensuse.org/tumbleweed/repo/non-oss" "default-repo-non-oss"
zypper -R $target addrepo --refresh --disable "http://download.opensuse.org/tumbleweed/repo/oss" "default-repo-oss"
zypper -R $target addrepo --refresh "http://download.opensuse.org/update/tumbleweed" "default-repo-update"
zypper -R $target addrepo --refresh "http://opensuse.c3sl.ufpr.br/tumbleweed/repo/non-oss" "ufpr-repo-non-oss"
zypper -R $target addrepo --refresh "http://opensuse.c3sl.ufpr.br/tumbleweed/repo/oss" "ufpr-repo-oss"
zypper lr -Pu

echo "Refreshing repositories"
zypper -R $target ref

echo "Adding locks"
zypper -R $target addlock "*yast*" "*packagekit*" "*PackageKit*" "*plymouth*" "postfix"

echo "Installing base patterns"
zypper -R $target install -t pattern base enhanced_base console 32bit devel_basis devel_python3 x11 basic_desktop

PARAMS=(
	##### kernel and bootloader
	kernel-default kernel-default-devel kernel-devel kernel-firmware-all purge-kernels-service
	grub2 grub2-i386-pc grub2-x86_64-efi

	##### filesystem utilities
	xfsprogs btrfsprogs ntfs-3g ntfsprogs dosfstools cryptsetup

	##### general CLI tools
	tmux iotop htop unrar unzip p7zip aria2 rsync neofetch tumbleweed-cli

	##### bluetooth, networking, audio
	bluez blueman NetworkManager NetworkManager-applet pulseaudio pavucontrol

	##### openGL, vulkan and X11 utilities
	vulkan-tools Mesa-demo-x arandr xdotool xwd

	##### fonts
	ubuntu-fonts

	##### additional services
	# openssh nginx

	##### development tools
	vim emacs-x11 git Catch2-devel clang colordiff go1.15 rust sbcl cmake clojure nodejs14 npm14 libvterm0 libvterm-devel

	##### virtualisation
	# virt-manager libvirt libvirt-daemon-qemu qemu-kvm

	##### i3wm and desktop utilities
	i3 rofi redshift feh brightnessctl

	##### X11 software
	MozillaFirefox chromium pidgin vlc geeqie transmission-gtk gimp inkscape okular

	##### gaming
	gzdoom wine wine-mono wine-gecko winetricks retroarch steam steamtricks
)
echo "Installing base packages"
zypper -R $target install ${PARAMS[@]}

echo "Setting up hostname, locale.conf, vconsole.conf and timezone"
echo $2 > $target/etc/hostname
echo "127.0.0.1 $2" >> $target/etc/hosts
echo "LANG=en_US.UTF-8" > $target/etc/locale.conf
echo "KEYMAP=br-abnt2" > $target/etc/vconsole.conf
cd $target/etc && ln -sf ../usr/share/zoneinfo/America/Sao_Paulo localtime
