#!/bin/bash

set -e
echo "🚀 Starting Ubuntu PHP + WordPress development setup..."

#Set PHP Version
PHP_VERSION="8.4"

#Set WordPress Coding Standards Version
WPCS_VERSION="3.3.0"

# Detect architecture
ARCH="$(dpkg --print-architecture)"

case "$ARCH" in
  amd64|arm64)
    echo "🖥 Detected architecture: $ARCH"
    ;;
  *)
    echo "❌ Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

# ---------------------------------------------------
# System update
# ---------------------------------------------------
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt upgrade -y

# ---------------------------------------------------
# Core packages
# ---------------------------------------------------
echo "📦 Installing core packages..."

sudo apt install -y \
  software-properties-common \
  curl \
  ca-certificates \
  gnupg \
  lsb-release \
  qemu-guest-agent

# ---------------------------------------------------
# PHP + required extensions for PHPCS / PHPCBF
# ---------------------------------------------------
echo "🐘 Installing PHP and required extensions..."

sudo apt install -y \
  "php${PHP_VERSION}" \
  "php${PHP_VERSION}"-cli \
  "php${PHP_VERSION}"-common \
  "php${PHP_VERSION}"-xml \
  "php${PHP_VERSION}"-mbstring \
  "php${PHP_VERSION}"-tokenizer \
  "php${PHP_VERSION}"-ctype

# Verify PHP
php -v

# ---------------------------------------------------
# Composer
# ---------------------------------------------------
echo "🎼 Installing Composer..."
EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
  echo "❌ Invalid Composer installer checksum"
  rm composer-setup.php
  exit 1
fi

php composer-setup.php --quiet
rm composer-setup.php
sudo mv composer.phar /usr/local/bin/composer

# ---------------------------------------------------
# WordPress Coding Standards
# ---------------------------------------------------
echo "📝 Installing WordPress Coding Standards..."
composer global config allow-plugins.dealerdirect/phpcodesniffer-composer-installer true
composer global require --dev wp-coding-standards/wpcs:"${WPCS_VERSION}" -W

# ---------------------------------------------------
# Ensure Composer global bin is in PATH
# ---------------------------------------------------
COMPOSER_BIN="$HOME/.config/composer/vendor/bin"

if [[ ":$PATH:" != *":$COMPOSER_BIN:"* ]]; then
  echo "🔧 Adding Composer global bin to PATH"
  echo 'export PATH="$HOME/.config/composer/vendor/bin:$PATH"' >> ~/.bashrc
  # Reload configuration
  source ~/.bashrc
fi

# ---------------------------------------------------
# Git + GitHub CLI
# ---------------------------------------------------
echo "🐙 Installing Git and GitHub CLI..."
sudo apt install -y git gh

# ---------------------------------------------------
# Cleanup for Microsoft GPG key (modern method)
# ---------------------------------------------------
echo "🧹 Cleaning up old VS Code APT configs (if any)..."

# Remove old repo files
sudo rm -f /etc/apt/sources.list.d/vscode.list
sudo rm -f /etc/apt/sources.list.d/code.list

# Remove old Microsoft keys (both legacy and modern locations)
sudo rm -f /etc/apt/trusted.gpg.d/microsoft.gpg
sudo rm -f /usr/share/keyrings/microsoft.gpg

# ---------------------------------------------------
# Add Microsoft GPG key (modern method)
# ---------------------------------------------------
echo "🔑 Installing Microsoft GPG key..."

curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
  | gpg --dearmor \
  | sudo tee /usr/share/keyrings/microsoft.gpg > /dev/null

sudo chmod 644 /usr/share/keyrings/microsoft.gpg

# ---------------------------------------------------
# Add VS Code repository
# ---------------------------------------------------
echo "📦 Adding VS Code APT repository..."

echo "deb [arch=$ARCH signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
  | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

# ---------------------------------------------------
# Visual Studio Code
# ---------------------------------------------------
echo "📝 Installing Visual Studio Code..."

sudo apt update
sudo apt install -y code

# Install VS Code Extensions
code --install-extension bmewburn.vscode-intelephense-client
code --install-extension valeryanm.vscode-phpsab
code --install-extension github.vscode-pull-request-github

# ---------------------------------------------------
# Install Docker Engine
# ---------------------------------------------------
echo "📝 Installing Docker Engine..."

# Remove old Docker Engine.
sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)

# Add Docker's official GPG key
sudo apt update
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

if getent group docker > /dev/null; then
  sudo usermod -aG docker $USER
else
  sudo groupadd docker
  sudo usermod -aG docker $USER
fi

# Start Docker on boot
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

# ---------------------------------------------------
# Install DDEV
# ---------------------------------------------------
echo "📝 Installing DDEV..."

sudo sh -c 'echo ""'
sudo apt-get update && sudo apt-get install -y curl
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://pkg.ddev.com/apt/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/ddev.gpg > /dev/null
sudo chmod a+r /etc/apt/keyrings/ddev.gpg
sudo sh -c 'echo ""'
echo "deb [signed-by=/etc/apt/keyrings/ddev.gpg] https://pkg.ddev.com/apt/ * *" | sudo tee /etc/apt/sources.list.d/ddev.list >/dev/null
sudo sh -c 'echo ""'
sudo apt-get update && sudo apt-get install -y ddev

# Allow browsers to trust HTTPS/TLS certificates served by DDEV
mkcert -install

echo "✅ Setup complete!"
echo "🔁 Close and restart Ubuntu."
