# Arch Linux Package Build Scripts

This directory contains scripts to build Arch Linux packages for the UGREEN LEDs controller using Docker.

## Structure

- **Dockerfile** - Creates an Arch Linux build environment with necessary tools
- **docker-run.sh** - Wrapper script to run commands in Docker container
- **build.sh** - Master build script that orchestrates the build process
- **build-dkms-pkg.sh** - Builds the DKMS kernel module package
- **build-utils-pkg.sh** - Builds the utilities package

## Usage

### Build Both Packages

```bash
./docker-run.sh
```

### Build Specific Version

```bash
./docker-run.sh <git-ref>
```

For example:

```bash
./docker-run.sh v0.3
./docker-run.sh main
./docker-run.sh abc123
```

## Output

The build process creates two Arch Linux packages in the `build/` directory:

- `led-ugreen-dkms-0.3-1-x86_64.pkg.tar.zst` - Kernel module (DKMS)
- `led-ugreen-utils-0.3-1-x86_64.pkg.tar.zst` - LED control utilities

## Installation

**Prerequisites**: Install kernel headers for your kernel before installing the DKMS package:

```bash
# For standard kernel
sudo pacman -S linux-headers

# For LTS kernel
sudo pacman -S linux-lts-headers

# For Zen kernel
sudo pacman -S linux-zen-headers
```

Install the packages using pacman:

```bash
sudo pacman -U led-ugreen-dkms-0.3-1-x86_64.pkg.tar.zst
sudo pacman -U led-ugreen-utils-0.3-1-x86_64.pkg.tar.zst
```

## How It Works

1. **Docker Environment**: Creates a clean Arch Linux build environment
2. **DKMS Package**: Installs kernel module source files for DKMS to compile
3. **Utils Package**: Compiles and installs LED control scripts, CLI tools, and systemd services
4. **PKGBUILD**: Uses Arch's native packaging format (PKGBUILD) with makepkg
5. **Output**: Produces compressed `.pkg.tar.zst` packages

## Key Differences from Debian

- Uses `PKGBUILD` instead of `debian/control`
- Uses `makepkg` instead of `dpkg-buildpackage`
- Package format is `.pkg.tar.zst` instead of `.deb`
- Systemd files go in `/usr/lib/systemd/system` instead of `/etc/systemd/system`
- DKMS integration handled by pacman hooks automatically

## Requirements

- Docker
- Bash

## Notes

- Build user is created in Docker (makepkg cannot run as root)
- All compilation happens inside the container for reproducibility
- DKMS will automatically build the module for your running kernel on installation
