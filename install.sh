#!/bin/bash
set -e

if [ `whoami` != root ]; then
    echo Please run this script as root or using sudo
    exit
fi

# Install Dependencies
apt update -y
apt upgrade -y
apt install -y network-manager curl git ntfs-3g hfsprogs mbpfan linux-headers-generic build-essential dkms bcmwl-kernel-source openssh-server

# mbpfan Config
echo "[general]

min_fan_speed = $(cat '/sys/devices/platform/applesmc.768/fan1_min')
max_fan_speed = $(cat '/sys/devices/platform/applesmc.768/fan1_max')
low_temp = 63
high_temp = 66
max_temp = 85
polling_interval = 1
" > /etc/mbpfan.conf
service mbpfan restart

curl -sfL https://raw.githubusercontent.com/linux-on-mac/mbpfan/master/mbpfan.service > /etc/systemd/system/mbpfan.service
systemctl enable mbpfan.service
systemctl daemon-reload
systemctl start mbpfan.service

# SSH Config
ufw allow ssh

echo "Include /etc/ssh/ssh_config.d/*.conf

Host *
PasswordAuthentication yes
SendEnv LANG LC_*
HashKnownHosts yes
" > /etc/ssh/ssh_config
systemctl enable ssh
systemctl start ssh

# Disable Lid Sleep
echo " HandleLidSwitch=ignore" >> /etc/systemd/logind.conf
service systemd-logind restart

# Disable Screen
echo 'GRUB_DEFAULT=0
GRUB_TIMEOUT_STYLE=hidden
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="consoleblank=60"
GRUB_CMDLINE_LINUX=""
' > /etc/default/grub
update-grub

# Install the Wifi Driver
git clone https://github.com/clnhub/rtl8192eu-linux.git
cd rtl8192eu-linux
./install_wifi.sh
cd ..

# Install K3S
curl -sfL https://get.k3s.io | sh -
