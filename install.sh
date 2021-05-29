#!/bin/bash

# Install Dependencies
sudo apt update -y
sudo apt install -y curl, git, ntfs-3g

# Install K3S
curl -sfL https://get.k3s.io | sh -