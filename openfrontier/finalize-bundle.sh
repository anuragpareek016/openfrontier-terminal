#!/bin/sh
set -eu

if [ "$#" -ne 2 ]; then
    echo "usage: $0 /path/to/OpenFrontier.app /path/to/OpenFrontier.icns" >&2
    exit 64
fi

bundle=$1
icon=$2
contents="$bundle/Contents"
macos="$contents/MacOS"
resources="$contents/Resources"
info="$contents/Info.plist"
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

if [ ! -d "$bundle" ] || [ ! -x "$macos/OpenFrontier" ]; then
    echo "OpenFrontier bundle or executable not found: $bundle" >&2
    exit 66
fi

patch_binary_exact() {
    old=$1
    new=$2
    file=$3
    if [ "${#old}" -ne "${#new}" ]; then
        echo "exact binary replacements must have equal lengths" >&2
        exit 65
    fi
    OLD=$old NEW=$new perl -0pi -e 's/\Q$ENV{OLD}\E/$ENV{NEW}/g' "$file"
}

patch_binary_cstring() {
    old=$1
    new=$2
    file=$3
    if [ "${#new}" -gt "${#old}" ]; then
        echo "replacement is longer than original string" >&2
        exit 65
    fi
    OLD=$old NEW=$new perl -0pi -e '$old=$ENV{OLD}; $new=$ENV{NEW}; $padded=$new . ("\0" x (length($old)-length($new))); s/\Q$old\E/$padded/g' "$file"
}

mv "$macos/OpenFrontier" "$macos/OpenFrontierCore"
/usr/bin/clang -O2 -arch arm64 -arch x86_64 -mmacosx-version-min=13.0 \
    "$root/openfrontier/Launcher.c" -o "$macos/OpenFrontier"

patch_binary_exact "com.mitchellh.ghostty" "com.openfrontier.term" "$macos/OpenFrontierCore"
patch_binary_cstring "ghostty/config.ghostty" "openfrontier/config" "$macos/OpenFrontierCore"
patch_binary_exact "ghostty/config" "of-term/config" "$macos/OpenFrontierCore"
patch_binary_exact "ghostty/crash" "of-term/crash" "$macos/OpenFrontierCore"
patch_binary_cstring "https://release.files.ghostty.org/appcast.xml" "about:blank" "$macos/OpenFrontierCore"
patch_binary_cstring "https://tip.files.ghostty.org/appcast.xml" "about:blank" "$macos/OpenFrontierCore"
patch_binary_cstring "https://ghostty.org/docs" "about:blank" "$macos/OpenFrontierCore"
patch_binary_cstring "https://github.com/ghostty-org/ghostty" "about:blank" "$macos/OpenFrontierCore"
patch_binary_cstring "Allow Ghostty to execute " "OpenFrontier may run " "$macos/OpenFrontierCore"
patch_binary_cstring "Allow Shortcuts to interact with Ghostty?" "Allow Shortcuts to use OpenFrontier?" "$macos/OpenFrontierCore"
patch_binary_cstring "Check the logs and restart Ghostty." "Restart OpenFrontier; check logs." "$macos/OpenFrontierCore"
patch_binary_cstring "Ghostty can automatically check for updates in the background." "OpenFrontier updates are managed locally." "$macos/OpenFrontierCore"
patch_binary_cstring "Ghostty could not be set as the default terminal application." "OpenFrontier could not become the default terminal." "$macos/OpenFrontierCore"
patch_binary_cstring "Ghostty doesn't allow Shortcuts." "OpenFrontier blocks Shortcuts." "$macos/OpenFrontierCore"
patch_binary_cstring "The Ghostty app isn't properly initialized." "OpenFrontier is not initialized." "$macos/OpenFrontierCore"
patch_binary_cstring "Update Ghostty and Restart" "Restart after local update" "$macos/OpenFrontierCore"
patch_binary_cstring "You're running a debug build of Ghostty! Performance will be degraded." "This OpenFrontier debug build has reduced performance." "$macos/OpenFrontierCore"
patch_binary_cstring "Ghostty Application Icon" "OpenFrontier App Icon" "$macos/OpenFrontierCore"
patch_binary_cstring "Ghostty app delegate is unavailable." "OpenFrontier is unavailable." "$macos/OpenFrontierCore"
patch_binary_cstring "Ghostty failed to initialize! If you're executing Ghostty from the command line" "OpenFrontier failed to initialize." "$macos/OpenFrontierCore"
patch_binary_cstring "Ghostty failed to launch the requested command:" "OpenFrontier could not launch command:" "$macos/OpenFrontierCore"
patch_binary_cstring "Run the Ghostty terminal emulator or a specific helper action." "Run OpenFrontier or a helper action." "$macos/OpenFrontierCore"
patch_binary_cstring "If no `+action` is specified, run the Ghostty terminal emulator." "If no `+action` is specified, run OpenFrontier." "$macos/OpenFrontierCore"

plugin="$contents/PlugIns/DockTilePlugin.plugin"
if [ -x "$plugin/Contents/MacOS/DockTilePlugin" ]; then
    patch_binary_exact "com.mitchellh.ghostty" "com.openfrontier.term" "$plugin/Contents/MacOS/DockTilePlugin"
    /usr/bin/plutil -replace CFBundleDisplayName -string "OpenFrontier Dock Tile Plugin" "$plugin/Contents/Info.plist"
    /usr/bin/plutil -replace CFBundleIdentifier -string "com.openfrontier.term-dock-tile" "$plugin/Contents/Info.plist"
fi

/usr/bin/plutil -replace CFBundleDisplayName -string OpenFrontier "$info"
/usr/bin/plutil -replace CFBundleName -string OpenFrontier "$info"
/usr/bin/plutil -replace CFBundleExecutable -string OpenFrontier "$info"
/usr/bin/plutil -replace CFBundleIdentifier -string com.openfrontier.term "$info"
/usr/bin/plutil -replace CFBundleIconFile -string OpenFrontier "$info"
/usr/bin/plutil -replace CFBundleIconName -string OpenFrontier "$info"
/usr/bin/plutil -replace OSAScriptingDefinition -string OpenFrontier.sdef "$info"
/usr/bin/plutil -replace UTExportedTypeDeclarations.0.UTTypeIdentifier -string com.openfrontier.surface-id "$info"
/usr/bin/plutil -replace UTExportedTypeDeclarations.0.UTTypeDescription -string "OpenFrontier Surface Identifier" "$info"
/usr/bin/plutil -replace SUEnableAutomaticChecks -bool false "$info"
/usr/bin/plutil -remove SUPublicEDKey "$info" 2>/dev/null || true
/usr/bin/plutil -remove GhosttyBuild "$info" 2>/dev/null || true
/usr/bin/plutil -remove GhosttyCommit "$info" 2>/dev/null || true
/usr/bin/plutil -insert OpenFrontierBuild -string personal "$info" 2>/dev/null || \
    /usr/bin/plutil -replace OpenFrontierBuild -string personal "$info"
/usr/bin/plutil -insert OpenFrontierCommit -string 332b2aefc "$info" 2>/dev/null || \
    /usr/bin/plutil -replace OpenFrontierCommit -string 332b2aefc "$info"

/usr/bin/ditto "$icon" "$resources/OpenFrontier.icns"
rm -f "$resources/Ghostty.icns" "$macos/ghostty"

if [ -f "$resources/Ghostty.sdef" ]; then
    rm -f "$resources/OpenFrontier.sdef"
    cp "$resources/Ghostty.sdef" "$resources/OpenFrontier.sdef"
    perl -pi -e 's/Ghostty/OpenFrontier/g; s/OpenFrontierScript/GhosttyScript/g' "$resources/OpenFrontier.sdef"
    rm -f "$resources/Ghostty.sdef"
fi

localized="$resources/en.lproj/Localizable.strings"
if [ -f "$localized" ]; then
    /usr/bin/plutil -replace "Ghostty failed to initialize!" -string "OpenFrontier failed to initialize!" "$localized" 2>/dev/null || true
    /usr/bin/plutil -replace "Allow Shortcuts to interact with Ghostty?" -string "Allow Shortcuts to interact with OpenFrontier?" "$localized" 2>/dev/null || true
    /usr/bin/plutil -replace "Ghostty Application Icon" -string "OpenFrontier Application Icon" "$localized" 2>/dev/null || true
    /usr/bin/plutil -replace "Update Ghostty and Restart" -string "Update OpenFrontier and Restart" "$localized" 2>/dev/null || true
fi

menu_strings="$resources/en.lproj/MainMenu.strings"
if [ -f "$menu_strings" ]; then
    /usr/bin/plutil -replace "Check for Updates..." -string "Updates Managed Locally" "$menu_strings" 2>/dev/null || true
fi

find "$resources/ghostty/shell-integration" -type f -print0 2>/dev/null | \
    xargs -0 perl -pi -e 's/\bghostty \+/OpenFrontier +/g; s/path join "ghostty"/path join "OpenFrontier"/g; s#\$GHOSTTY_BIN_DIR/"ghostty"#\$GHOSTTY_BIN_DIR/"OpenFrontier"#g' || true

/usr/bin/xattr -cr "$bundle"
/usr/bin/codesign --force --deep --sign - "$bundle"
/usr/bin/codesign --verify --deep --strict --verbose=2 "$bundle"

"$macos/OpenFrontier" +version
