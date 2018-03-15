---
title: "Install Arch Linux on Hyper V"
date: 2018-03-15T01:28:32-07:00
draft: false
---
Windows 10 Pro edition ships with a fully functioned hyper-v, which is a high-performance virtual machine widely used by the industry.

Thanks to the bad reputation for being unfriendly to newcomers, Hyper-V is a lot less-known by the public, especially when compared to VMware or Virtual Box. The problem of these two virtual machines is either expensive (VMware) or low-performance (VBox). So I finally decided to investigate on Hyper-V and try the state-of-the-art technology from Microsoft.

I'm a fan of [Arch Linux](https://www.archlinux.org/) and it happens to be dramatically difficult to install since it doesn't have an installer, which means you need to have a clear mind of how an operating system boots. Any questions are not welcomed, you should really try hard to figure out the whole process before you read this post.

#### Preparation
The first step is to enable Hyper-V in `turn windows features on or off`, you will probably need a restart to fully set up.

Then you create a new virtual machine, select the `second generation` (the latest one), by doing so you will boot on a `UEFI` machine.

To boot from a Linux image, you should disable the `secure boot` from the `security` panel.

Then comes the tricky part, to connect to the Internet. The idea is to set up a `virtual switch` and connect both your host machine and guest machine to it, you may google around about the network `switch` before you go ahead. The simplest workaround here is to create an `internal` virtual switch and connect your `external` network (wireless or ethernet) to it, then attach this `virtual switch` to the guest machine. 

Now you have a virtual machine with the Internet connection, half done!

#### Install Arch Linux on a UEFI Machine
Then you follow this [tutorial](https://wiki.archlinux.org/index.php/Installation_guide) and you install it successfully.


(important tip: **it's always important to read the official wiki in Arch Linux community**)

Well, I can still give you some suggestions.

partition scheme

1. EFI system partition `/dev/sda1` with 300M size, FAT32 formatted.

2. SWAP partition `/dev/sda2` with twice of your memory size, SWAP on.

3. Root partition `/dev/sda3` all the remaining spaces, EXT4 formatted.

Install `boot loader`

```bash
# pacman -S grub efibootmgr dosfstools os-prober mtools
# mkdir /boot/EFI
# mount /dev/sda1 /boot/EFI  #Mount FAT32 EFI partition 
# grub-install --target=x86_64-efi  --bootloader-id=grub_uefi --recheck
# grub-mkconfig -o /boot/grub/grub.cfg
```

#### Post installation
Arch Linux is famous for its user contributed package management, `pacman` is the official one and you may need another to install package from `AUR`, say, `yarourt`. 

You will also need a desktop environment, like `Gnome` or `KDE`.

Unlike `VMWare` which ships with a tool to handle window resize, you need to **manually** set the screen resolution to the grub config, which means you can't adjust the screen resolution on the fly.

You need to modify `/etc/default/grub`, add `video=hyperv_fb:1920x1080` to the `GRUB_CMDLINE_LINUX_DEFAULT`. 

So your lines ends up looking like this: `GRUB_CMDLINE_LINUX_DEFAULT="quiet splash video=hyperv_fb:1280x720"`. Then you need to `update-grub` and reboot.

That's it, hope you enjoy the journey of installing Arch Linux.