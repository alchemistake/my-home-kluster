#!/bin/bash
set -e

if [ `whoami` != root ]; then
    echo Please run this script as root or using sudo
    exit 2
fi

if [ "$#" -ne 3 ]; then
    echo "Usage:
    sudo ./install.sh \$ZT_NETWORK_ID \$NODE_NAME \$PLEX_CLAIM
    "
    exit 2
fi

CYAN='\033[0;36m'
NC='\033[0m'

NETWORK_ID=$1
NODE_NAME=$2
CLAIM=$3

# Install Dependencies
apt update -y
apt upgrade -y
apt install -y network-manager curl git ntfs-3g hfsprogs mbpfan linux-headers-generic build-essential dkms bcmwl-kernel-source openssh-server

# ZeroTier Install
curl -s https://install.zerotier.com | sudo bash
zerotier-cli join $NETWORK_ID
printf "${CYAN}Please continue after confirming the device on ZT Dashboard and Eth Bridging is enabled${NC}"
read throw_away_variable

# Kustomize Install
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
mv kustomize /usr/local/bin/

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
setterm -powerdown 1

# Install the Wifi Driver
git clone https://github.com/clnhub/rtl8192eu-linux.git
cd rtl8192eu-linux
./install_wifi.sh
cd ..
rm -rf rtl8192eu-linux

# Install K3S
curl -sfL https://get.k3s.io | sh -s - --disable servicelb --node-name $NODE_NAME

# Own the cluster
mkdir -p /home/$SUDO_USER/.kube
chown $SUDO_USER /etc/rancher/k3s/k3s.yaml
chown $SUDO_USER /home/$SUDO_USER/.kube
cp /etc/rancher/k3s/k3s.yaml /home/$SUDO_USER/.kube/config
chown $SUDO_USER /home/$SUDO_USER/.kube/config

# Initial Install of Kustomize
kustomize build apps | kubectl apply -f -
kubectl create secret generic claim -n plex --from-literal=claim=$CLAIM