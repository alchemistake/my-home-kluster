#!/bin/bash

# Install Dependencies
sudo apt-get install -y curl git

# Install K3S
curl -sfL https://get.k3s.io | sh -

# Install Zerotier
curl -s https://install.zerotier.com | sudo bash

zerotier-cli join abfd31bd47704311 # The Generalized Network
zerotier-cli join abfd31bd47879a95 # The Quake Network