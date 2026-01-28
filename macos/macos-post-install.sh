#!/bin/bash

set -e
echo "🚀 Starting macOS PHP + WordPress development setup..."

# Set PHP Version
PHP_VERSION="8.4"

# Set WordPress Coding Standards Version
WPCS_VERSION="3.3.0"

# Detect architecture
ARCH="$(uname -m)"

case "$ARCH" in
  arm64|x86_64)
    echo "🖥 Detected architecture: $ARCH"
    ;;
  *)
    echo "❌ Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

# ---------------------------------------------------
# Check if Homebrew is installed
# ---------------------------------------------------
if ! command -v brew &> /dev/null; then
  echo "❌ Homebrew is not installed. Please install Homebrew first:"
  echo "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
  exit 1
fi

echo "✅ Homebrew is installed"

# ---------------------------------------------------
# Update Homebrew
# ---------------------------------------------------
echo "🔄 Updating Homebrew..."
brew update
brew upgrade

# ---------------------------------------------------
# Core packages
# ---------------------------------------------------
echo "📦 Installing core packages..."

brew install \
  curl \
  ca-certificates \
  gnupg \
  wget \
  git \
  gh

# ---------------------------------------------------
# PHP + required extensions for PHPCS / PHPCBF
# ---------------------------------------------------
echo "🐘 Installing PHP ${PHP_VERSION} and required extensions..."

# Tap the Homebrew PHP repository
brew tap shivammathur/php

# Install PHP with required extensions
brew install shivammathur/php/php@${PHP_VERSION}

# Link PHP to make it available in PATH
brew link php@${PHP_VERSION} --force

# Verify PHP
php -v

# ---------------------------------------------------
# Composer
# ---------------------------------------------------
echo "🎼 Installing Composer..."

# Install composer using Homebrew
brew install composer

# Verify Composer
composer --version

# ---------------------------------------------------
# WordPress Coding Standards
# ---------------------------------------------------
echo "📝 Installing WordPress Coding Standards..."

composer global config allow-plugins.dealerdirect/phpcodesniffer-composer-installer true
composer global require --dev wp-coding-standards/wpcs:"${WPCS_VERSION}" -W

# ---------------------------------------------------
# Ensure Composer global bin is in PATH
# ---------------------------------------------------
COMPOSER_BIN="$HOME/.composer/vendor/bin"

if [[ ":$PATH:" != *":$COMPOSER_BIN:"* ]]; then
  echo "🔧 Adding Composer global bin to PATH"
  echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> ~/.zshrc
  echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> ~/.bash_profile
  # Reload configuration
  source ~/.zshrc 2>/dev/null || true
fi

# ---------------------------------------------------
# Visual Studio Code
# ---------------------------------------------------
echo "📝 Installing Visual Studio Code..."

brew install visual-studio-code

# Install VS Code Extensions
code --install-extension bmewburn.vscode-intelephense-client
code --install-extension valeryanm.vscode-phpsab
code --install-extension github.vscode-pull-request-github

# ---------------------------------------------------
# Colima (Container runtime for macOS)
# ---------------------------------------------------
echo "🐳 Installing Colima..."

# Install Colima and Docker client
brew install colima docker

# Start Colima
if ! colima status &> /dev/null; then
  echo "🚀 Starting Colima..."
  colima start
else
  echo "✅ Colima is already running"
fi

# Verify Docker client connectivity
docker --version

# ---------------------------------------------------
# Install DDEV
# ---------------------------------------------------
echo "📝 Installing DDEV..."

brew install ddev/ddev/ddev

# Verify DDEV
ddev version

# ---------------------------------------------------
# Install mkcert for local HTTPS support
# ---------------------------------------------------
echo "🔐 Installing mkcert for local HTTPS certificates..."

brew install mkcert

# Create local CA if it doesn't exist
if ! mkcert -CAROOT > /dev/null 2>&1; then
  mkcert -install
fi

# ---------------------------------------------------
# Completed
# ---------------------------------------------------
echo "✅ Setup complete!"
echo ""
echo "⚠️  IMPORTANT NEXT STEPS:"
echo "1. Close and restart your Terminal"
echo "2. Verify Colima is running with 'colima status'"
echo "3. Run 'docker --version' to verify Docker client is working"
echo ""
echo "Ready for PHP + WordPress development on macOS! 🚀"
