#!/bin/bash
set -e

# Install Dependencies
sudo apt upgrade -y
sudo apt install -y curl git ntfs-3g hfsprogs

# Install K3S
curl -sfL https://get.k3s.io | sh -
