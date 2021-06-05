#!/bin/bash
set -e

# Install Dependencies
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y network-manager curl git ntfs-3g hfsprogs mbpfan linux-headers-generic build-essential dkms

# mbpfan Config
sudo echo "[general]

min_fan_speed = $(cat '/sys/devices/platform/applesmc.768/fan*_min')
max_fan_speed = $(cat '/sys/devices/platform/applesmc.768/fan*_max')
low_temp = 63
high_temp = 66
max_temp = 85
polling_interval = 1
" >> /etc/mbpfan.conf
sudo service mbpfan restart

# Install the Wifi Driver
git clone https://github.com/clnhub/rtl8192eu-linux.git
cd rtl8192eu-linux
./install_wifi.sh
cd ..

# Install K3S
curl -sfL https://get.k3s.io | sh -
