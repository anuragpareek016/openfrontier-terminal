# OpenFrontier Terminal Architecture & Customization Suite

This repository pins the terminal engine to upstream revision `332b2aefc` (version 1.3.1) and applies the OpenFrontier product identity, ergonomic eye-care architectures, tactile e-paper textures, live shaders, custom keybindings, and typography management utilities.

## Identity & System Paths
- **Product Name**: `OpenFrontier`
- **Bundle Identifier**: `com.openfrontier.term`
- **Application Bundle**: `/Applications/OpenFrontier.app`
- **Configuration File**: `~/.config/openfrontier/config`
- **Themes Directory**: `~/.config/openfrontier/themes`
- **Shaders Directory**: `~/.config/openfrontier/shaders`
- **CLI Commands**: `~/.local/bin/` (`font`, `theme`, `shad`, `paper-config`)
- **State Directory**: `~/.local/state/openfrontier`
- **AppleScript Dictionary**: `OpenFrontier.sdef`

---

## Quick Installation & Post-Reset Restoration
To immediately deploy or restore all configurations, themes, shaders, and CLI utilities on a fresh host:
```bash
cd openfrontier
chmod +x install-customizations.sh
./install-customizations.sh
```

---

## Typography & Font Architecture (`font`)
Controlled by the interactive `font` CLI utility (`~/.local/bin/font`):
- **Default Font**: `CaskaydiaCove Nerd Font` (Microsoft Cascadia Code typography with cursive italic curves)
- **Default Size**: `22pt`, with `font-thicken = true` for high-contrast legibility.
- **Curated Catalogue**:
  - `jetbrains`: JetBrains Mono NF (developer ergonomics, tall x-height)
  - `firacode`: Fira Code NF (iconic programming ligatures `->`, `!=`, `===`)
  - `hack`: Hack NF (crisp geometric monospace)
  - `cascadia`: CaskaydiaCove NF (modern cursive italic curves)
  - `geist`: Geist Mono NF (Vercel minimalist Swiss design)
  - `meslo`: MesloLGS NF (Powerlevel10k prompt standard)
  - `monaco`: Apple Monaco (classic Cupertino bitmap heritage)
  - `menlo`: Apple Menlo (balanced macOS system monospace)

Usage:
```bash
font            # Interactive typography selector
font cascadia   # Set CaskaydiaCove Nerd Font
font size 22    # Set font size to 22pt
font thicken    # Toggle font thickening for anti-aliased legibility
```

---

## Eye-Care & Contrast Themes (`theme`)
Controlled by the interactive `theme` CLI utility (`~/.local/bin/theme`):
14 curated palettes designed to eliminate retinal glare, blue-light strain, and macular fatigue:
1. `kanagawa`: Katsushika Hokusai woodblock & stone (autumn pigments, warm slate) [Active Default]
2. `matrix`: Original Terminal Pro neon green on pitch black
3. `parchment`: Antique book page (cream paper `#fbf1c7` & charcoal ink)
4. `e-ink`: Kindle Paperwhite (monochrome carbon ink on matte paper `#f2f2f0`)
5. `sepia`: Aged library manuscript (walnut ink & amber glow `#f4ecd8`)
6. `slate-dark`: Gruvbox dark velvet (matte charcoal & ivory)
7. `everforest`: Forest moss & bark (macular-relaxing earth tones)
8. `zenwritten`: Japanese handmade washi paper (minimalist sumi ink)
9. `nord-calm`: Scandinavian arctic twilight (muted pastel slate)
10. `catppuccin`: Catppuccin Mocha (velvety pastel crust)
11. `tokyonight`: Midnight blue twilight (calm cyber slate)
12. `solarized-dark`: CIELAB deep ocean (precision ergonomic contrast)
13. `lotus`: Antique rice paper (floral dyes & sumi ink)
14. `solarized-light`: Daylight ivory (CIELAB ergonomic reading)

Usage:
```bash
theme           # Interactive theme browser with live preview
theme kanagawa  # Switch directly to Kanagawa Wave
theme parchment # Switch to Antique Parchment E-Paper
```

---

## GPU Shaders & Tactile E-Paper (`shad`)
Controlled by the multi-shader stacking manager `shad` (`~/.local/bin/shad`):
Supports simultaneous composition (e.g. Physical Cellulose Paper Grain + Blaze Cursor Trail):
- `trail`: Orange Blaze cursor trail (custom physics-based particle wake)
- `lightning`: Electric cursor lightning
- `paper`: Physical E-Paper & organic cellulose pulp texture (6 tiers: Low, Mid, High/Washi, Flat Kindle, Library Lamp, Librera)
- `bloom`: Neon cyberpunk glow
- `crt`: Retro curved CRT monitor with scanlines & shadow mask
- `matrix-rain`: Falling digital glyph rain
- `matrix-hallway`: 3D perspective cyber tunnel
- `starfield`: Hyperspace warp field
- `glitchy`: Cyber chromatic aberration & split
- `vhs`: Retro VHS tape distortion & tracking noise

Usage:
```bash
shad            # Interactive shader switcher & status HUD
shad trail      # Enable cursor blaze trail
shad paper mid  # Enable Mid-Tier Physical E-Paper grain
shad off        # Disable all shaders
```

---

## Native Window & Tiling Engine Keybindings
- `Super + D`: Split right
- `Super + Shift + D`: Split down
- `Super + [` / `Super + ]`: Navigate splits
- `Super + Alt + Left/Right/Up/Down`: Directional split navigation
- `Super + Enter`: Toggle split zoom (maximize focused split)
- `Super + Ctrl + =`: Equalize all split dimensions
- `Super + Up` / `Super + Down`: Semantic shell prompt jump (OSC 133 telemetry)
- `Super + Backspace`: Delete entire line (`\x15`)
- `Alt + Backspace`: Delete word backward (`\x17`)

---

## App Icon & Packaging
- `AppIconSource.swift`: Generates the canonical transparent 1024-pixel icon with standard macOS optical inset.
- `MakeIcns.swift`: Packages PNG iconset into ICNS.
- `finalize-bundle.sh`: Finalizes personal builds, applies bundle identity, and enforces ad-hoc code signatures.
