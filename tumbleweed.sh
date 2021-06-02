#!/bin/bash

set -e

if [[ $EUID -ne 0 ]]; then
   echo ">>> You must be root to do this." 1>&2
   exit 1
fi

if [[ -z "$1" ]]; then
    echo ">>> No target directory supplied."
    exit 2
fi

if [[ -z "$2" ]]; then
    echo ">>> No target hostname supplied."
    exit 2
fi

target=$(realpath $1)

if [[ -d $target/dev ]]; then
    echo ">>> Target directory already contains either a partial or full installation: $target"
    echo ">>> Sleeping for 10 seconds... Press Ctrl+C to abort execution."
    sleep 10
fi

mkdir -p $target/dev
mkdir -p $target/sys
mkdir -p $target/proc
mount -t devtmpfs devtmpfs $target/dev
mount -t devpts devpts $target/dev/pts
mount -t sysfs sysfs $target/sys
mount -t proc proc $target/proc

echo ">>> Enabling repositories"
zypper -R $target addrepo --refresh -p 90 --disable "http://dl.google.com/linux/chrome/rpm/stable/x86_64"      "google-chrome"
zypper -R $target addrepo --refresh -p 90 --disable "https://download.nvidia.com/opensuse/tumbleweed"          "nvidia"
zypper -R $target addrepo --refresh -p 90 "http://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed" "packman"
zypper -R $target addrepo --refresh "http://download.opensuse.org/tumbleweed/repo/non-oss"                     "default-repo-non-oss"
zypper -R $target addrepo --refresh "http://download.opensuse.org/tumbleweed/repo/oss"                         "default-repo-oss"
zypper -R $target addrepo --refresh "http://download.opensuse.org/update/tumbleweed"                           "default-repo-update"
zypper lr -Pu

echo ">>> Refreshing repositories"
zypper -R $target ref

echo ">>> Adding locks"
zypper -R $target addlock "*yast*" "*packagekit*" "*PackageKit*" "*plymouth*" "postfix" "pulseaudio"

echo ">>> Installing base patterns"
zypper --non-interactive -R $target install -t pattern base enhanced_base console 32bit devel_basis devel_python3 x11 basic_desktop

PARAMS=(
    ##### kernel and bootloader
    kernel-default kernel-default-devel kernel-devel kernel-firmware-all purge-kernels-service
    grub2 grub2-i386-pc grub2-x86_64-efi

    ##### filesystem utilities
    xfsprogs btrfsprogs ntfs-3g ntfsprogs dosfstools exfatprogs e2fsprogs cryptsetup

    ##### general CLI tools
    fish tmux iotop htop unrar unzip p7zip aria2 rsync neofetch youtube-dl

    ##### bluetooth, networking, audio, polkit
    bluez blueman NetworkManager NetworkManager-applet polkit polkit-gnome
    pipewire pipewire-modules pipewire-pulseaudio pavucontrol

    ##### openGL, vulkan and X11 utilities
    vulkan-tools Mesa-demo-x arandr xdotool xwd xev lxterminal

    ##### fonts
    ubuntu-fonts google-roboto-fonts google-roboto-mono-fonts google-roboto-slab-fonts

    ##### additional services
    chrony
    # openssh nginx

    ##### development tools
    ack vim emacs-x11 git Catch2-devel colordiff cmake libvterm0 libvterm-devel
    clang go1.16 rust sbcl clojure nodejs16 npm16 nasm yasm gdb entr

    ##### virtualisation
    # virt-manager libvirt libvirt-daemon-qemu qemu-kvm

    ##### docker
    # docker python3-docker-compose

    ##### i3wm and desktop utilities
    i3 rofi redshift feh brightnessctl

    ##### X11 software
    MozillaFirefox pidgin vlc geeqie transmission-gtk gimp inkscape okular

    ##### chromium/chrome - repository must be enabled for chrome
    # chromium chromium-plugin-widevinecdm chromium-ffmpeg-extra
    # google-chrome-stable

    ##### gaming
    # gzdoom wine wine-mono wine-gecko winetricks lutris retroarch steam steamtricks
)
echo ">>> Installing base packages"
zypper --non-interactive -R $target install ${PARAMS[@]}

echo ">>> Setting up hostname"
echo $2 > $target/etc/hostname
echo "127.0.0.1 $2" >> $target/etc/hosts

echo ">>> Setting up locale.conf: LANG=en_US.UTF-8"
echo "LANG=en_US.UTF-8" > $target/etc/locale.conf

echo ">>> Setting up vconsole.conf: KEYMAP=us"
echo "KEYMAP=us" > $target/etc/vconsole.conf

echo ">>> It's advised that you change these settings if necessary"
echo ">>> It's also advised for you to correctly modify /etc/fstab"
echo ">>> It's also advised for you to set your timezone"
echo ">>> It's also advised for you to install and configure a bootloader"
echo ">>> Thank you for using SUSEstrap!"
