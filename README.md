# susestrap
Bootstrap openSUSE systems for faster and more customisable installations.
Currently only openSUSE Tumbleweed is supported.

> This tool requires a working installation of [`zypper`](https://github.com/openSUSE/zypper). openSUSE and SLE systems naturally come with it preinstalled.
> Packages are available for: [Debian](https://packages.debian.org/search?keywords=zypper&searchon=names&exact=1&suite=all&section=all), [Ubuntu](https://packages.ubuntu.com/search?keywords=zypper&searchon=names&exact=1&suite=all&section=all), [Arch Linux](https://aur.archlinux.org/packages/zypper/), [Fedora](https://src.fedoraproject.org/rpms/zypper)
> If you're not using one of the aforementioned distributions, it may be available on your distro's repos, or you can always [build it yourself](https://en.opensuse.org/openSUSE:Zypper_development#Building_Zypper).

### First steps

Create your partitions, mount your install filesystems, clone this repository, then run:

`bash tumbleweed.sh <target_directory> <target_hostname>`

Where these values are:

`target_directory`: The directory where the new system will be installed into.
`target_hostname`: Hostname for the new system.

### Next steps

After the system is installed, you may mount (`/sys` `/dev` `/dev/pts` `/proc`), `chroot` into it, install GRUB or another bootloader, edit `/etc/fstab`, `/etc/vconsole.conf` and `/etc/locale.conf`, set `/etc/localtime` to something more fitting, and it's business as usual, all the sweet Linux-from-inside-out stuff we know and love.

### Inspirations

Installing systems from the inside-out is quick and practical for advanced users.
Plus, you get a lot of system customisability ahead of time.
We should be able to specify which packages should be downloaded, and which ones should be locked out (avoided altogether).
This isn't a new idea: Arch (pacstrap), Gentoo (tarballs) and Debian (via debootstrap) have been doing this for a long time, among other systems.
`zypper` is just so neat, it's the only required tool for openSUSE, this script is just some bare-bones automation.
