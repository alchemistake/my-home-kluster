#!/bin/bash

# Install Dependencies
sudo apt install -y curl, git

# Install K3S
curl -sfL https://get.k3s.io | sh -

# Install Zerotier
curl -s 'https://raw.githubusercontent.com/zerotier/ZeroTierOne/master/doc/contact%40zerotier.com.gpg' | gpg --import && \
if z=$(curl -s 'https://install.zerotier.com/' | gpg); then echo "$z" | sudo bash; fi
# curl -s https://install.zerotier.com | sudo bash

zerotier-cli join abfd31bd47704311 # The Generalized Network
zerotier-cli join abfd31bd47879a95 # The Quake Network