#!/bin/bash

# Apply a Win11OS variant consistently.
#
# Applying only the look-and-feel leaves two settings behind, which is why a
# theme switch used to keep dark (Kvantum) widgets and dark Qt apps:
#   * the concrete Kvantum theme lives in ~/.config/Kvantum/kvantum.kvconfig
#   * the window decoration and plasma theme are separate lookup keys
#
# Usage: ./apply.sh [dark|light]   (default: dark)

VARIANT="${1:-dark}"

case "${VARIANT}" in
  dark)
    LNF="com.github.yeyushengfan258.Win11OS-dark"
    SCHEME="Win11OSDark"
    KVANTUM="Win11OS-dark"
    CURSOR="Win10OS-cursors"
    ;;
  light)
    LNF="com.github.yeyushengfan258.Win11OS-light"
    SCHEME="Win11OSLight"
    KVANTUM="Win11OS-light"
    CURSOR="ArcDusk-cursors"
    ;;
  *)
    echo "Usage: $0 [dark|light]" >&2
    exit 1
    ;;
esac

if ! command -v plasma-apply-lookandfeel >/dev/null 2>&1; then
  echo "plasma-apply-lookandfeel not found; use System Settings instead." >&2
  exit 1
fi

if [ ! -d "/usr/share/plasma/look-and-feel/${LNF}" ] && \
   [ ! -d "$HOME/.local/share/plasma/look-and-feel/${LNF}" ]; then
  echo "'${LNF}' is not installed. Run ./install.sh first." >&2
  exit 1
fi

echo "Applying ${VARIANT} variant..."

# Look-and-feel brings icons, widget style, plasma theme, aurorae decoration,
# window switcher layout and the taskbar template.
plasma-apply-lookandfeel -a "${LNF}"

# Colors and cursor are stored outside the look-and-feel and must be applied
# explicitly, otherwise a previous scheme keeps leaking into widgets.
plasma-apply-colorscheme "${SCHEME}"
plasma-apply-cursortheme "${CURSOR}"

# Kvantum ignores widgetStyle=kvantum and reads its concrete theme here.
# Without this a light switch keeps rendering Qt apps with the dark theme.
if command -v kwriteconfig6 >/dev/null 2>&1; then
  kwriteconfig6 --file "${HOME}/.config/Kvantum/kvantum.kvconfig" \
                --group General --key theme "${KVANTUM}"
fi

# Let plasmashell reload the desktop theme without restarting the session.
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.refreshCurrentShell >/dev/null 2>&1
command -v kbuildsycoca6 >/dev/null 2>&1 && kbuildsycoca6 --noincremental >/dev/null 2>&1

echo "Done. Restart already running Qt apps (Dolphin, System Settings, Konsole)"
echo "so they pick up the new Kvantum theme."
