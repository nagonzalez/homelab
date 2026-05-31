#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# ANSI color codes for premium terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${BLUE}${BOLD}==================================================${NC}"
echo -e "${CYAN}${BOLD}       Kyle Burton's Bake Installer & Init        ${NC}"
echo -e "${BLUE}${BOLD}==================================================${NC}"

INSTALL_DIR="$HOME/bin"
BAKE_BIN="$INSTALL_DIR/bake"
BAKE_URL="https://raw.githubusercontent.com/kyleburton/bake/master/bake"

# Function to check bash version of a specific executable
get_bash_major_version() {
    local bash_path="$1"
    if [ -x "$bash_path" ]; then
        "$bash_path" -c 'echo "${BASH_VERSINFO[0]}"' 2>/dev/null || echo 0
    else
        echo 0
    fi
}

# Function to find a modern bash (>= 4.0) on the system
find_modern_bash() {
    local candidate
    # Common locations on macOS
    local candidates=(
        "/opt/homebrew/bin/bash"
        "/usr/local/bin/bash"
        "/bin/bash"
    )

    # Add any other bash in PATH
    while IFS= read -r candidate; do
        if [[ -n "$candidate" ]]; then
            candidates+=("$candidate")
        fi
    done < <(which -a bash 2>/dev/null || true)

    for candidate in "${candidates[@]}"; do
        local version
        version=$(get_bash_major_version "$candidate")
        if [ "$version" -ge 4 ]; then
            echo "$candidate"
            return 0
        fi
    done

    return 1
}

# Helper function to check if a directory is actually writable by trying to touch a test file
is_writable() {
    local dir="$1"
    if [ -d "$dir" ]; then
        if touch "$dir/.brew_write_test" &>/dev/null; then
            rm -f "$dir/.brew_write_test"
            return 0
        else
            return 1
        fi
    fi
    return 0 # If it doesn't exist, we don't treat it as an active error
}

# Function to diagnose system errors (Xcode Command Line Tools & Homebrew)
diagnose_system() {
    echo -e "\n${YELLOW}${BOLD}🔍 System Diagnostics:${NC}"
    
    # 1. Check Xcode Command Line Tools
    if ! git --version &>/dev/null; then
        echo -e "${RED}✗ Xcode Command Line Tools are missing or misconfigured.${NC}"
        echo -e "  To fix, run: ${BOLD}xcode-select --install${NC}"
        echo -e "  If already installed but failing, try: ${BOLD}sudo xcode-select --reset${NC}"
    else
        echo -e "${GREEN}✓ Xcode Command Line Tools are active.${NC}"
    fi

    # 2. Check Homebrew write permissions
    if command -v brew &>/dev/null; then
        local brew_dirs=(
            "/usr/local/Homebrew"
            "/usr/local/Cellar"
            "/usr/local/Caskroom"
            "/usr/local/Frameworks"
            "/usr/local/bin"
            "/usr/local/etc"
            "/usr/local/include"
            "/usr/local/lib"
            "/usr/local/opt"
            "/usr/local/sbin"
            "/usr/local/share"
            "/usr/local/var"
            "/usr/local/var/homebrew"
            "/usr/local/var/homebrew/tmp"
            "/usr/local/var/homebrew/locks"
        )
        local unwritable_dirs=()

        for dir in "${brew_dirs[@]}"; do
            if [ -d "$dir" ] && ! is_writable "$dir"; then
                unwritable_dirs+=("$dir")
            fi
        done

        if [ ${#unwritable_dirs[@]} -gt 0 ]; then
            echo -e "${RED}✗ The following Homebrew directories are not writable by $(whoami):${NC}"
            for dir in "${unwritable_dirs[@]}"; do
                echo -e "  - $dir"
            done
            echo -e "\n  To fix, execute the following commands in your terminal (recursively chowns/chmods all parent Homebrew folders):${NC}"
            echo -e "  ${CYAN}sudo chown -R \$(whoami) /usr/local/Cellar /usr/local/Caskroom /usr/local/Frameworks /usr/local/bin /usr/local/etc /usr/local/include /usr/local/lib /usr/local/opt /usr/local/sbin /usr/local/share /usr/local/var /usr/local/Homebrew${NC}"
            echo -e "  ${CYAN}chmod -R u+w /usr/local/Cellar /usr/local/Caskroom /usr/local/Frameworks /usr/local/bin /usr/local/etc /usr/local/include /usr/local/lib /usr/local/opt /usr/local/sbin /usr/local/share /usr/local/var /usr/local/Homebrew${NC}"
        else
            echo -e "${GREEN}✓ Homebrew write permissions are healthy.${NC}"
        fi
    else
        echo -e "${YELLOW}i Homebrew is not installed. You can install it from: https://brew.sh${NC}"
    fi
}



# --- MAIN EXECUTION FLOW ---

# 1. Look for an existing modern bash
MODERN_BASH_PATH=""
if MODERN_BASH_PATH=$(find_modern_bash); then
    echo -e "${GREEN}✓ Found modern bash at: $MODERN_BASH_PATH (Version: $(get_bash_major_version "$MODERN_BASH_PATH"))${NC}"
else
    echo -e "${YELLOW}i Modern bash (v4+) not found on system. Default macOS bash (v3.2) is too old for 'bake'.${NC}"
    echo -e "${YELLOW}Attempting to install modern bash via Homebrew...${NC}"
    
    if command -v brew &>/dev/null; then
        # Try to install bash
        if brew install bash; then
            if MODERN_BASH_PATH=$(find_modern_bash); then
                echo -e "${GREEN}✓ Successfully installed and located modern bash at: $MODERN_BASH_PATH${NC}"
            else
                echo -e "${RED}Error: Brew install completed but modern bash still cannot be found.${NC}"
                diagnose_system
                exit 1
            fi
        else
            echo -e "${RED}Error: Failed to install bash via Homebrew.${NC}"
            diagnose_system
            exit 1
        fi
    else
        echo -e "${RED}Error: Homebrew is not available to install a modern bash.${NC}"
        diagnose_system
        exit 1
    fi
fi

# 2. Ensure installation directory exists
if [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}Creating installation directory at $INSTALL_DIR...${NC}"
    mkdir -p "$INSTALL_DIR"
fi

# 3. Download bake
echo -e "${YELLOW}Downloading bake script...${NC}"
if curl -sSfL "$BAKE_URL" -o "$BAKE_BIN"; then
    chmod +x "$BAKE_BIN"
    echo -e "${GREEN}✓ Successfully downloaded bake to $BAKE_BIN${NC}"
else
    echo -e "${RED}Error: Failed to download bake from $BAKE_URL${NC}" >&2
    exit 1
fi

# 4. Patch the shebang of bake to use the modern bash
echo -e "${YELLOW}Configuring bake to use modern bash ($MODERN_BASH_PATH)...${NC}"
# Read the file content, skip the first line (the old shebang), and prepend the new shebang
TEMP_FILE=$(mktemp)
echo "#!$MODERN_BASH_PATH" > "$TEMP_FILE"
tail -n +2 "$BAKE_BIN" >> "$TEMP_FILE"
mv "$TEMP_FILE" "$BAKE_BIN"
chmod 755 "$BAKE_BIN"
echo -e "${GREEN}✓ Configured shebang in $BAKE_BIN${NC}"

# 5. Check if bake bin is in PATH
if command -v bake &>/dev/null; then
    echo -e "${GREEN}✓ 'bake' is accessible in your current PATH.${NC}"
else
    echo -e "\n${YELLOW}${BOLD}⚠️ Action Required: Add $INSTALL_DIR to your PATH${NC}"
    echo -e "To run 'bake' globally, please add $INSTALL_DIR to your PATH."
    
    SHELL_NAME=$(basename "$SHELL")
    SHELL_CONFIG=""
    if [ "$SHELL_NAME" = "zsh" ]; then
        SHELL_CONFIG="$HOME/.zshrc"
    elif [ "$SHELL_NAME" = "bash" ]; then
        if [ -f "$HOME/.bash_profile" ]; then
            SHELL_CONFIG="$HOME/.bash_profile"
        else
            SHELL_CONFIG="$HOME/.bashrc"
        fi
    fi

    if [ -n "$SHELL_CONFIG" ]; then
        echo -e "You can do this by running:"
        echo -e "  ${CYAN}echo 'export PATH=\"\$PATH:$INSTALL_DIR\"' >> $SHELL_CONFIG${NC}"
        echo -e "  ${CYAN}source $SHELL_CONFIG${NC}"
    else
        echo -e "Please append the following line to your shell configuration file:"
        echo -e "  ${CYAN}export PATH=\"\$PATH:$INSTALL_DIR\"${NC}"
    fi
fi

# 6. Verify version
echo -e "\n${BLUE}Verifying installation...${NC}"
VERSION=$("$BAKE_BIN" version 2>/dev/null || echo "unknown")
echo -e "${GREEN}Bake version: $VERSION${NC}"

echo -e "${BLUE}${BOLD}==================================================${NC}"
echo -e "${GREEN}${BOLD}Setup script completed!${NC}"
echo -e "${BLUE}${BOLD}==================================================${NC}"
