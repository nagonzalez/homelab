#!/usr/bin/env bash

# Script to automate downloading macOS Sequoia and building a bootable ISO for VMware Fusion.
# Must be run on macOS.

set -euo pipefail

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0;0m' # No Color

echo -e "${BLUE}=== macOS Sequoia ISO Builder ===${NC}"

INSTALLER_PATH="/Applications/Install macOS Sequoia.app"
ISO_OUTPUT_DIR="/Users/mac/Documents/homelab/vm/iso"
ISO_PATH="${ISO_OUTPUT_DIR}/Sequoia.iso"
TMP_DMG="/tmp/Sequoia.dmg"
VOLUME_NAME="Sequoia"
MOUNT_POINT="/Volumes/${VOLUME_NAME}"

# Ensure output directory exists
mkdir -p "${ISO_OUTPUT_DIR}"

# 1. Idempotency Check: Exit early if the ISO already exists
if [ -f "${ISO_PATH}" ]; then
    echo -e "${GREEN}✓ Bootable macOS Sequoia ISO already exists at: ${ISO_PATH}. Nothing to do.${NC}"
    exit 0
fi

# 2. Ensure we are running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}✗ Error: This script must be run on macOS.${NC}"
    exit 1
fi

# 3. Check for sudo privileges upfront
echo -e "${YELLOW}i This script requires administrative privileges to run 'createinstallmedia'.${NC}"
sudo -v

# Keep-alive: update existing sudo time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


# 3. Check/Download macOS Sequoia Installer
if [ ! -d "${INSTALLER_PATH}" ]; then
    echo -e "${YELLOW}i macOS Sequoia Installer not found at ${INSTALLER_PATH}.${NC}"
    echo -e "${BLUE}→ Downloading macOS Sequoia installer (approx. 13GB)...${NC}"
    # softwareupdate is native to macOS and fetches installers directly from Apple
    softwareupdate --fetch-full-installer --full-installer-version 15.7.7
    
    if [ ! -d "${INSTALLER_PATH}" ]; then
        echo -e "${RED}✗ Error: Failed to download macOS Sequoia Installer.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Installer downloaded successfully.${NC}"
else
    echo -e "${GREEN}✓ Found existing macOS Sequoia Installer at ${INSTALLER_PATH}.${NC}"
fi

# 4. Cleanup trap for temporary files
cleanup() {
    echo -e "${YELLOW}i Cleaning up temporary files...${NC}"
    if [ -d "/Volumes/Install macOS Sequoia" ]; then
        echo "Detaching installer volume..."
        hdiutil detach "/Volumes/Install macOS Sequoia" -force || true
    fi
    if [ -d "${MOUNT_POINT}" ]; then
        echo "Detaching temporary volume..."
        hdiutil detach "${MOUNT_POINT}" -force || true
    fi
    if [ -f "${TMP_DMG}" ]; then
        rm -f "${TMP_DMG}"
    fi
    if [ -f "/tmp/Sequoia.cdr" ]; then
        rm -f "/tmp/Sequoia.cdr"
    fi
}
trap cleanup EXIT

# 5. Create blank disk image
echo -e "${BLUE}→ Creating a blank 18GB DMG image...${NC}"
if [ -f "${TMP_DMG}" ]; then
    rm -f "${TMP_DMG}"
fi
hdiutil create -o "${TMP_DMG}" -size 18432m -volname "${VOLUME_NAME}" -layout SPUD -fs HFS+J

# 6. Mount blank image
echo -e "${BLUE}→ Mounting DMG...${NC}"
hdiutil attach "${TMP_DMG}" -noverify -mountpoint "${MOUNT_POINT}"

# 7. Use createinstallmedia to write installer files
echo -e "${BLUE}→ Writing installer media (this takes several minutes)...${NC}"
sudo "${INSTALLER_PATH}/Contents/Resources/createinstallmedia" --volume "${MOUNT_POINT}" --nointeraction

# 8. Unmount installer disk image
echo -e "${BLUE}→ Detaching installer image...${NC}"
hdiutil detach "/Volumes/Install macOS Sequoia"

# 9. Convert DMG to CDR (ISO format)
echo -e "${BLUE}→ Converting DMG to ISO format...${NC}"
if [ -f "/tmp/Sequoia.cdr" ]; then
    rm -f "/tmp/Sequoia.cdr"
fi
hdiutil convert "${TMP_DMG}" -format UDTO -o /tmp/Sequoia.cdr

# 10. Move and rename to destination
echo -e "${BLUE}→ Moving ISO to final destination: ${ISO_PATH}...${NC}"
mv /tmp/Sequoia.cdr "${ISO_PATH}"

echo -e "${GREEN}✓ Success! Bootable macOS Sequoia ISO created at: ${ISO_PATH}${NC}"
