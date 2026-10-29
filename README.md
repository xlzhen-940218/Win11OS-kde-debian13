## Win11OS KDE Theme

Win11OS is a Windows 11 style theme for the KDE Plasma desktop. It contains:

- Aurorae window decorations (dark / light)
- Kvantum widget style
- Plasma color schemes
- Plasma desktop themes (dark / light)
- Plasma look-and-feel (global theme) packages with a Windows 11 taskbar layout
- Wallpapers
- SDDM login themes for Plasma 5 and Plasma 6

## Plasma 6 fixes

The theme was originally written for Plasma 5. It now works on Plasma 6
(tested on Plasma 6.3.6); the following fixes are included in this repository:

- **SVGs are gzip-compressed (`.svgz`)**. Plasma 6 only loads `.svgz` from a
  desktop theme and silently ignores plain `.svg`, which left the panel
  background, tooltips, buttons and many icons unstyled. Every widget/dialog
  SVG is stored as `.svgz` — when editing one, keep it gzip-compressed.
- **Missing Plasma 6 widgets restored**. `monitor.svgz`, `radiobutton.svgz` and
  `switch.svgz` were absent from Win11OS-light and have been added, so both
  variants now cover the same widget set as the Plasma 6 default theme.
- **Broken Aurorae references removed**. `maximize.svg`, `minimize.svg` and
  `restore.svg` referenced `xlink:href="#g1000"`/`#g1051` elements that do not
  exist, which made kwin log `qt.svg: link #gNNN is undefined`. The dead
  `<use>` elements were deleted; buttons and frame rendering are correct again.
- **Kvantum theme selection**. `widgetStyle=kvantum` only selects the engine;
  the concrete theme is read from `~/.config/Kvantum/kvantum.kvconfig`. The
  installer now writes `theme=Win11OS-dark` when no theme is configured, so Qt
  applications are no longer unstyled.
- **SDDM 6.0 support**. The QML themes used `org.kde.plasma.plasma5support`
  (Plasma 5 only) to read the Caps Lock state. They now use
  `org.kde.plasma.private.keyboardindicator.KeyState`, and `Login.qml` no
  longer imports the removed module.
- **Windows 11 taskbar layout**. Both look-and-feel packages ship
  `contents/layouts/org.kde.plasma.desktop-layout.js`: a 48px bottom panel with
  the start menu, centred task buttons, system tray and clock.
- **Start button icon**. Win11-icon-theme ships an Apple silhouette for
  `start-here-kde*`; the installer replaces it with the Windows logo that the
  icon theme already provides.

The `The theme "Win11OS-dark" uses the legacy metadata.desktop` message in the
kwin/plasmashell log is only a notice and does not affect rendering.

## Donate

If you like my project, you can buy me a coffee:

<span class="paypal"><a href="https://www.paypal.me/yeyushengfan258" title="Donate to this project using Paypal"><img src="https://www.paypalobjects.com/webstatic/mktg/Logo/pp-logo-100px.png" alt="PayPal donate button" /></a></span>

## Dependencies

The look-and-feel `defaults` point at these external themes:

| Purpose | Theme | Source |
| --- | --- | --- |
| Icons | `Win11`, `Win11-dark` | https://github.com/yeyushengfan258/Win11-icon-theme |
| Cursor (dark) | `Win10OS-cursors` | https://github.com/yeyushengfan258/Win10OS-cursors |
| Cursor (light) | `ArcDusk-cursors` | https://github.com/yeyushengfan258/ArcDusk-cursors |

`install.sh` downloads and installs them automatically (it needs `git` and
network access). Pass `--no-deps` to skip this step and install them manually.
Kvantum itself must be installed from your distribution's package manager.

## Installation

Install for the current user (into `~/.local/share`):

```sh
./install.sh
```

Install system wide:

```sh
sudo ./install.sh
```

## Apply

```sh
plasma-apply-lookandfeel -a com.github.yeyushengfan258.Win11OS-dark
plasma-apply-colorscheme Win11OSDark
systemctl --user restart plasma-plasmashell   # reload the desktop theme
```

To use the light variant, apply `com.github.yeyushengfan258.Win11OS-light` and
`Win11OSLight` instead. Applying the global theme from *System Settings → Global
Theme* and ticking **Use default layout** also recreates the Windows 11 taskbar
(start menu, centred tasks, system tray and clock).

If the panel still looks unstyled, log out and back in once so kwin and
plasmashell reload the Aurorae theme and the desktop theme.

## Uninstall

```sh
./uninstall.sh
```

## License

GNU GPL v3

## view

![view](View-1.png?raw=true)
![view](View-2.png?raw=true)
![view](View-3.png?raw=true)
![view](View-4.png?raw=true)
![view](View-5.png?raw=true)
![view](View-6.png?raw=true)
