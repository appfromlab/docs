# Setup Ubuntu VM on Apple Silicon

**Requirements**

- Apple Silicon hardware (etc. M1, M2, M3, M4) with minimum 16Gb RAM and 100Gb disk space.
- UTM app.
- Ubuntu Desktop ARM64 ISO.

**What will be installed?**

- Ubuntu Desktop for ARM64.
- Visual Studio Code and extensions.
- PHP 8.4.
- WordPress Coding Standards.
- Docker Engine.
- DDEV.

## Download Ubuntu Desktop

Use the LTS version of Ubuntu Desktop for ARM64

1. Go to [https://cdimage.ubuntu.com/releases/](https://cdimage.ubuntu.com/releases/)
1. Select folder 24.04.3/releases/.
1. Download Desktop Image 64-bit ARM - [ubuntu-24.04.3-desktop-arm64.iso](https://cdimage.ubuntu.com/releases/24.04.3/release/ubuntu-24.04.3-desktop-arm64.iso)

## Download UTM Virtualization App for Mac

1. Install the latest release from [github.com/utmapp/UTM/releases](https://github.com/utmapp/UTM/releases).
1. Create a New Virtual Machine
- Virtualize > Linux
- Memory: `6144` Mib
- CPU Cores: `6`.
- Enable display output.
- Enable hardware OpenGL.
- Continue.
- `Use Apple Virtualization`.
- Enable Rosetta on Linux (x86_64 Emulation).
- Boot from ISO Image.
- Browse > Select ubuntu-X.X.X-desktop-arm64.iso.
- Continue.
- Size: `100` Gib.
- Continue.
- Name: `AFL - Ubuntu`.
- Save.
- Play.

## Install Ubuntu

1. Try or install Ubuntu.
1. English > Next.
1. English (US).
1. Use wired connection.
1. Skip.
1. Install Ubuntu.
1. Interactive Installation.
- Default Selection.
1. Install Recommended Proprietary Software ? Uncheck > Next.
1. Erase disk and install Ubuntu.
1. Create Account.
- Name: jarvis
- Host: jarvis-pc
- Username: jarvis
- Password: <set own password>
- Next
1. Set timezone
1. Install.
1. Shutdown.

## Remove Ubuntu ISO

1. In the UTM app > Select `AFL - Ubuntu`.
1. Top right > Gear Settings.
1. Drives > Delete Zero KB Image.
1. Save.

## Start Ubuntu VM

1. Enable Ubuntu Pro > Skip.
1. Help Improve Ubuntu > No > Next > Finish.

### Fix Ubuntu VM hang in login / user switch screen

```bash
systemctl is-enabled NetworkManager-wait-online.service systemd-networkd-wait-online.service
systemctl disable systemd-networkd.service
```

### Set Natural Scrolling

```bash
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true
gsettings set org.gnome.desktop.peripherals.mouse natural-scroll true
```

### Run Post Install Script

This will install PHP, Composer, WordPress Coding Standards, Visual Studio Code, Docker Engine and DDEV.

Auto-install:

```bash
sudo apt update
sudo apt upgrade -y
sudo apt install curl -y
curl -L "https://raw.githubusercontent.com/appfromlab/docs/main/macos/ubuntu-post-install.sh" -o ~/Desktop/ubuntu-post-install.sh
chmod +x ubuntu-post-install.sh
./ubuntu-post-install.sh
```

For manual installation, open a Terminal in your desktop:

```bash
touch ubuntu-post-install.sh
chmod +x ubuntu-post-install.sh
```

- Copy the file content from [ubuntu-post-install.sh](https://github.com/appfromlab/docs/macos/ubuntu-post-install.sh)
- Paste content into your `ubuntu-post-install.sh` file on your Desktop.
- Save and run the terminal command below.
- Delete this file after successful installation.

```bash
./ubuntu-post-install.sh
```

### Test

1. Restart your Ubuntu VM.
1. Open terminal and check if everything is working.

```bash
# Check Composer and PHP
composer -V

# Check DDEV
ddev -v

# Check Docker
sudo systemctl status docker
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

2. VS Code > Top search bar > Enter the following.

```bash
>Git:clone
```
