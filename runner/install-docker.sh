#!/bin/bash

set -e

running_text() {
    local text="$1"
    local color="${2:-\033[32m}" 
    local delay="${3:-0.02}"      

    echo -ne "$color"

    for (( i=0; i<${#text}; i++ )); do
        echo -n "${text:$i:1}"
        sleep "$delay"
    done

    echo -ne "\033[0m"
    echo ""
}

RED="\033[31m"
YELLOW="\033[33m"

# Install dependencies quietly
echo ""
running_text "Updating system and installing dependencies..."
sudo apt update -y >/dev/null 2>&1
sudo apt install curl git wget build-essential micro -y >/dev/null 2>&1

echo ""
running_text "Installing jemalloc to optimize memory usage..."
sudo apt install libjemalloc-dev -y >/dev/null 2>&1

if command -v docker compose >/dev/null 2>&1; then
    echo ""
    running_text "Docker Compose is already installed. Skipping installation."
else
    echo ""
    running_text "Installing Docker Compose"
    curl -fsSL https://get.docker.io | bash >/dev/null 2>&1
    running_text "Docker Compose installation complete."
fi

# Pull Geth and Lighthouse Docker images
echo ""
running_text "Pulling Da-Geth and Da-Lighthouse Docker images..."

# Pull the latest Geth Docker image
docker pull ethereum/client-go:v1.13.14 >/dev/null 2>&1

# Pull the latest Lighthouse Docker image
docker pull sigp/lighthouse:latest >/dev/null 2>&1

echo ""
running_text "Docker images for Da-Geth and Da-Lighthouse have been pulled successfully."

echo ""
running_text "WARNING: Before proceeding, please ensure that you are prepared to become a validator. You need to set up your node data and be ready to join the DaVinci Protocol." "$RED"

# Clone Mainnet Data
echo ""
running_text "[Calling On-Chain Data] Requesting to Become a DaVinci Validator Member..."
git clone https://github.com/davinchi-protocol/da-validator >/dev/null 2>&1
cd da-validator
echo ""

sleep 3
running_text "Wait A Moment......."
echo ""

sleep 3
running_text "Calling Complete!"
echo ""
running_text "Get Ready to be a part of DaVinci Node Earners and please edit your node metadata like address, graffiti, and name at folder da-validator" "$YELLOW"
echo ""