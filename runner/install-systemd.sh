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

    # back to default text color
    echo -ne "\033[0m"
    echo ""
}

RED="\033[31m"

# Install dependencies quietly
echo ""
running_text "Updating system and installing dependencies..."
sudo apt update -y >/dev/null 2>&1
sudo apt install curl git wget build-essential micro -y >/dev/null 2>&1

echo ""
running_text "Installing jemalloc to optimize memory usage..."
sudo apt install libjemalloc-dev -y >/dev/null 2>&1

# Determine the user's device type
OS="$(uname -s)"
ARCH="$(uname -m)"
GETH_URL=""
LIGHTHOUSE_URL=""

echo ""
running_text "Detecting device type..."

# Set the download URLs based on OS and architecture
case "$OS" in
    Linux)
        if [ "$ARCH" == "x86_64" ]; then
            GETH_URL="https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.13.14-2bd6bd01.tar.gz"
            LIGHTHOUSE_URL="https://github.com/sigp/lighthouse/releases/download/v5.3.0/lighthouse-v5.3.0-x86_64-unknown-linux-gnu.tar.gz"
        elif [[ "$ARCH" == *"arm"* || "$ARCH" == *"aarch"* ]]; then
            GETH_URL="https://gethstore.blob.core.windows.net/builds/geth-linux-arm-1.13.14-2bd6bd01.tar.gz"
            LIGHTHOUSE_URL="https://github.com/sigp/lighthouse/releases/download/v5.3.0/lighthouse-v5.3.0-aarch64-unknown-linux-gnu.tar.gz"
        fi
        ;;
    Darwin)
        if [ "$ARCH" == "x86_64" ]; then
            GETH_URL="https://gethstore.blob.core.windows.net/builds/geth-darwin-amd64-1.13.14-2bd6bd01.tar.gz"
            LIGHTHOUSE_URL="https://github.com/sigp/lighthouse/releases/download/v5.3.0/lighthouse-v5.3.0-x86_64-apple-darwin.tar.gz"
        elif [ "$ARCH" == "arm64" ]; then
            echo "No compatible Lighthouse binary available for macOS arm64 architecture."
            exit 1
        fi
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# Check if URLs are set
if [ -z "$GETH_URL" ] || [ -z "$LIGHTHOUSE_URL" ]; then
    echo "No compatible binaries found for architecture: $ARCH"
    exit 1
fi

# Download and install Geth
echo ""
running_text "Downloading Geth binary for $OS on $ARCH architecture..."
wget "$GETH_URL" -O geth.tar.gz >/dev/null 2>&1

echo ""
running_text "Extracting Geth binary..."
tar -xvf geth.tar.gz >/dev/null 2>&1
GETH_DIR=$(tar -tf geth.tar.gz | head -n 1 | cut -f1 -d"/")
sudo cp "$GETH_DIR/geth" /usr/local/bin/geth
sudo chmod +x /usr/local/bin/geth

# Download and install Lighthouse
echo ""
running_text "Downloading Lighthouse binary for $OS on $ARCH architecture..."
wget "$LIGHTHOUSE_URL" -O lighthouse.tar.gz >/dev/null 2>&1

echo ""
running_text "Extracting Lighthouse binary..."
tar -xvf lighthouse.tar.gz >/dev/null 2>&1
sudo cp lighthouse /usr/local/bin/lighthouse
sudo chmod +x /usr/local/bin/lighthouse

# Clean up
rm -rf geth.tar.gz "$GETH_DIR" lighthouse.tar.gz "$LIGHTHOUSE_DIR"

echo ""
running_text "WARNING: Before proceeding, please ensure that you are prepared to become a validator, You need to set up your node data and be ready to join the DaVinci Protocol." "$RED"

echo ""
# Use /dev/tty to ensure read prompt works in all contexts
read -p "Are you willing to be a validator? (yes/no): " answer < /dev/tty

if [[ "$answer" == "yes" || "$answer" == "Yes" ]]; then
    echo ""
    running_text "Thank you! You have chosen to be a validator. Be sure to follow our documentation to set up your node."
else
    echo ""
    running_text "No problem! You can use DaVinci Node without being a validator."
fi

sleep 3

# Clone Mainnet Data
echo ""
running_text "[Calling On-Chain Data] Requesting to Become a DaVinci Validator Member..."
git clone https://github.com/davinchi-protocol/da-validator >/dev/null 2>&1
cd da-validator
echo ""
git checkout main

sleep 3
running_text "Calling Complete!"
echo ""
running_text "Get Ready to be a part of DaVinci Node Earners and please edit your node metadata like address, graffiti, and name at folder da-validator" "$YELLOW"
echo ""