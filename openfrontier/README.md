# OpenFrontier Terminal

This branch pins the terminal engine to upstream revision `332b2aefc`
(version 1.3.1) and applies the OpenFrontier product identity at the source
and bundle layers.

External identity:

- Product name: `OpenFrontier`
- Bundle identifier: `com.openfrontier.term`
- Configuration: `~/.config/openfrontier/config`
- State: `~/.local/state/openfrontier`
- AppleScript dictionary: `OpenFrontier.sdef`
- Network updates: disabled; builds are installed locally

Compatibility names such as `xterm-ghostty`, the `GHOSTTY_*` shell protocol,
and internal engine/resource names are intentionally retained where changing
them would break remote terminfo or shell integration.

The source build requires Zig 0.15.2 and a full Xcode 26 installation. The
current machine has Command Line Tools only, so the installed personal build
is finalized with `openfrontier/finalize-bundle.sh` until full Xcode is
available.

## App icon

`AppIconSource.swift` generates the canonical transparent 1024-pixel icon.
It uses the standard macOS optical inset and rounded tile so OpenFrontier has
the same perceived size as Apple's Dock icons. `MakeIcns.swift` packages a
complete PNG iconset when `iconutil` cannot create ICNS files on beta macOS
hosts.
