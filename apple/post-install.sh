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

sudo composer --version

# ---------------------------------------------------
# WordPress Coding Standards
# ---------------------------------------------------
echo "📝 Installing WordPress Coding Standards..."
sudo composer global config allow-plugins.dealerdirect/phpcodesniffer-composer-installer true
sudo composer global require --dev wp-coding-standards/wpcs:"${WPCS_VERSION}" -W

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

echo "🧹 Fix network for Ubuntu VM hanging on user login/switching..."

# ---------------------------------------------------
# Fix Ubuntu VM hanging on login / user switching
# ---------------------------------------------------
systemctl is-enabled NetworkManager-wait-online.service systemd-networkd-wait-online.service || true
systemctl disable systemd-networkd.service || true

echo "✅ Setup complete!"
echo "🔁 Close and restart terminal."
