# Setup macOS for PHP Development

**Requirements**

- Apple Silicon or Intel Mac hardware with minimum 8GB RAM.
- Homebrew package manager.
- macOS Monterey or newer.

**What will be installed?**

- Homebrew (if not already installed).
- PHP 8.4.
- Composer.
- WordPress Coding Standards.
- Visual Studio Code and extensions.
- Colima (lightweight container runtime).
- Docker CLI.
- DDEV.

## Create a New macOS User

We want a separate Mac OS user account for personal and development.

1. Open macOS Settings > Users & Groups.
1. Add User > `Standard`.

[https://support.apple.com/](https://support.apple.com/en-sg/guide/mac-help/mchl3e281fc9/mac)

### Give sudo access to the new user.

Check the username of the new user.

```bash
dscl . list /Users | grep -v '^_’
```

Add the username to a custom sudoers file.

```bash
sudo visudo -f /etc/sudoers.d/custom
```

Type `i` to insert a new line and enter the following line to give sudo access.

```
username ALL=(ALL) ALL
```

To quit edit mode, press `ESC` on the keyboard.

To save type `:wq` and press `ENTER` on the keyboard.

## Switch to your new user account

1. Logoff from your macOS.
2. Select your new user.

## Install Homebrew

If you don't have Homebrew installed, run:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Once completed, you will see a `Next Steps` section in the terminal. Copy the commands to create a shortcut command for `brew`.

Verify installation:

```bash
brew --version
```

## Run Post Install Script

This will install most of the softwares.

### Auto-install:

```bash
curl -L "https://raw.githubusercontent.com/appfromlab/docs/main/macos/macos-post-install.sh" -o ~/Desktop/macos-post-install.sh
chmod +x ~/Desktop/macos-post-install.sh
~/Desktop/macos-post-install.sh
```

### Manual installation:

1. Create a new file on your Desktop called `macos-post-install.sh`

```bash
touch ~/Desktop/macos-post-install.sh
chmod +x ~/Desktop/macos-post-install.sh
```

2. Copy the file content from [macos-post-install.sh](macos-post-install.sh)
3. Paste content into your `macos-post-install.sh` file on your Desktop
4. Save and run the terminal command below

```bash
~/Desktop/macos-post-install.sh
```

## Test Installation

1. Close and reopen your Terminal
2. Check if everything is working

```bash
# Check PHP version
php -v

# Check Composer
composer -V

# Check DDEV
ddev -V

# Check Docker
docker --version
```

## Connect to Github

```bash
gh auth login
```

## Open VS Code

1. Go to your project folder and enter the following. The period (.) at the end means open the current folder in VS Code.

```bash
code .
```

2. Use the integrated Git Clone feature in VS Code by pressing `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac) and select "Git: Clone"

## Optional Installation

- [Github Desktop](https://desktop.github.com/download/) - GUI for GitHub.
- [LocalWP](https://localwp.com/) - GUI to install WordPress on local computer.
