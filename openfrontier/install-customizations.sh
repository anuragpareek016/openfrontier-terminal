#!/usr/bin/env bash
# ==============================================================================
# OpenFrontier Terminal Customization & Architecture Installer
# Restores configurations, themes, shaders, and CLI tools on a fresh macOS host
# Operator: Anurag Pareek (@krsna016) | OpenFrontier Labs
# ==============================================================================

set -eo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
TARGET_CONFIG_DIR="$HOME/.config/openfrontier"
TARGET_BIN_DIR="$HOME/.local/bin"

echo "⚡ Installing OpenFrontier Terminal Architecture..."

# 1. Create target directories
mkdir -p "$TARGET_CONFIG_DIR/themes"
mkdir -p "$TARGET_CONFIG_DIR/shaders"
mkdir -p "$TARGET_BIN_DIR"

# 2. Install base config if not present
if [[ ! -f "$TARGET_CONFIG_DIR/config" ]]; then
    echo "  › Installing default configuration to $TARGET_CONFIG_DIR/config"
    cp "$SCRIPT_DIR/config/config" "$TARGET_CONFIG_DIR/config"
else
    echo "  › Existing config detected at $TARGET_CONFIG_DIR/config (preserving, backup created)"
    cp "$TARGET_CONFIG_DIR/config" "$TARGET_CONFIG_DIR/config.bak.$(date +%s)"
fi

# 3. Synchronize themes
echo "  › Synchronizing 14 curated ergonomic themes..."
cp -R "$SCRIPT_DIR/themes/"*.conf "$TARGET_CONFIG_DIR/themes/"

# 4. Synchronize shaders
echo "  › Synchronizing 20 GLSL GPU shaders & e-paper textures..."
cp -R "$SCRIPT_DIR/shaders/"*.glsl "$TARGET_CONFIG_DIR/shaders/"

# 5. Install CLI commands to ~/.local/bin
echo "  › Linking custom CLI management utilities to $TARGET_BIN_DIR..."
for cmd in font theme shad paper-config; do
    if [[ -f "$SCRIPT_DIR/commands/$cmd" ]]; then
        chmod +x "$SCRIPT_DIR/commands/$cmd"
        ln -sf "$SCRIPT_DIR/commands/$cmd" "$TARGET_BIN_DIR/$cmd"
        echo "    ✔ $cmd -> $TARGET_BIN_DIR/$cmd"
    fi
done

# 6. Verify PATH
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    echo "  ⚠ Note: Ensure '$HOME/.local/bin' is included in your PATH in ~/.zshrc:"
    echo "    export PATH=\"$HOME/.local/bin:\$PATH\""
fi

echo "✔ OpenFrontier Terminal architecture successfully installed."
echo "  Launch OpenFrontier or reload with USR2 signal."
