#!/bin/bash

SRC_DIR=$(cd "$(dirname "$0")" && pwd)
ROOT_UID=0
INSTALL_DEPS=1

usage() {
cat << EOF
Usage: $0 [OPTION]...

  -d, --no-deps    Do not download the Win11 icon theme and cursor themes
  -h, --help       Show this help

Install the Win11OS Plasma theme. Run it as your normal user to install into
~/.local/share, or with sudo to install system wide.
EOF
}

for arg in "$@"; do
  case "${arg}" in
    --no-deps) INSTALL_DEPS=0 ;;
    -h|--help) usage; exit 0 ;;
  esac
done

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  AURORAE_DIR="/usr/share/aurorae/themes"
  SCHEMES_DIR="/usr/share/color-schemes"
  PLASMA_DIR="/usr/share/plasma/desktoptheme"
  LAYOUT_DIR="/usr/share/plasma/layout-templates"
  LOOKFEEL_DIR="/usr/share/plasma/look-and-feel"
  KVANTUM_DIR="/usr/share/Kvantum"
  WALLPAPER_DIR="/usr/share/wallpapers"
  ICONS_DIR="/usr/share/icons"
else
  AURORAE_DIR="$HOME/.local/share/aurorae/themes"
  SCHEMES_DIR="$HOME/.local/share/color-schemes"
  PLASMA_DIR="$HOME/.local/share/plasma/desktoptheme"
  LAYOUT_DIR="$HOME/.local/share/plasma/layout-templates"
  LOOKFEEL_DIR="$HOME/.local/share/plasma/look-and-feel"
  KVANTUM_DIR="$HOME/.config/Kvantum"
  WALLPAPER_DIR="$HOME/.local/share/wallpapers"
  ICONS_DIR="$HOME/.local/share/icons"
fi

THEME_NAME=Win11OS

[[ ! -d ${AURORAE_DIR} ]] && mkdir -p ${AURORAE_DIR}
[[ ! -d ${SCHEMES_DIR} ]] && mkdir -p ${SCHEMES_DIR}
[[ ! -d ${PLASMA_DIR} ]] && mkdir -p ${PLASMA_DIR}
[[ ! -d ${LOOKFEEL_DIR} ]] && mkdir -p ${LOOKFEEL_DIR}
[[ ! -d ${KVANTUM_DIR} ]] && mkdir -p ${KVANTUM_DIR}
[[ ! -d ${WALLPAPER_DIR} ]] && mkdir -p ${WALLPAPER_DIR}

install() {
  cp -r ${SRC_DIR}/aurorae/*                                                         ${AURORAE_DIR}
  cp -r ${SRC_DIR}/color-schemes/*.colors                                            ${SCHEMES_DIR}
  cp -r ${SRC_DIR}/Kvantum/*                                                         ${KVANTUM_DIR}
  cp -r ${SRC_DIR}/plasma/desktoptheme/*                                             ${PLASMA_DIR}
  cp -r ${SRC_DIR}/plasma/look-and-feel/*                                            ${LOOKFEEL_DIR}
  cp -r ${SRC_DIR}/wallpaper/*                                                       ${WALLPAPER_DIR}
}

# The theme name is duplicated in plasma/look-and-feel metadata.json, so keep the
# theme folders and the Kvantum theme name in sync with WHAT TO INSTALL.
install_dependency() {
  local url="${1}"
  shift
  local names=("$@")
  local missing=0
  local name

  for name in "${names[@]}"; do
    [ -d "${ICONS_DIR}/${name}" ] || missing=1
  done

  if [ "$missing" -eq 0 ]; then
    echo "  - ${names[*]} already installed, skipping"
    return
  fi

  if ! command -v git >/dev/null 2>&1; then
    echo "  - ${names[*]} is missing and git is not available; install it manually:" >&2
    echo "    ${url}" >&2
    return
  fi

  echo "  - installing ${names[*]} from ${url}"
  local tmp
  tmp=$(mktemp -d)
  if ! git clone --depth 1 "${url}" "${tmp}/src" >/dev/null 2>&1; then
    echo "  - failed to clone ${url}" >&2
    rm -rf "${tmp}"
    return
  fi
  ( cd "${tmp}/src" && ./install.sh ) || echo "  - ${name} reported an error" >&2
  rm -rf "${tmp}"
}

# The theme's defaults point at icon and cursor themes that are not part of this
# repository. Install the ones the look-and-feel expects.
install_dependencies() {
  if [ "${INSTALL_DEPS}" -eq 0 ]; then
    echo "Skipping icon/cursor dependencies (--no-deps)."
    return
  fi

  echo "Installing icon and cursor dependencies into ${ICONS_DIR}..."
  [[ ! -d ${ICONS_DIR} ]] && mkdir -p ${ICONS_DIR}

  install_dependency "https://github.com/yeyushengfan258/Win11-icon-theme" Win11 Win11-dark
  install_dependency "https://github.com/yeyushengfan258/Win10OS-cursors" Win10OS-cursors
  install_dependency "https://github.com/yeyushengfan258/ArcDusk-cursors" ArcDusk-cursors
}

# Win11-icon-theme ships an Apple silhouette for start-here-kde, so the panel
# start button would not look like Windows. Replace it with the Windows logo
# that the theme already provides as a status icon.
patch_start_icons() {
  local logo="${ICONS_DIR}/Win11/status/32/start-here.svg"
  [ -f "${logo}" ] || logo="${ICONS_DIR}/Win11-dark/status/32/start-here.svg"
  if [ ! -f "${logo}" ]; then
    echo "  - start icon patch skipped (Win11 icon theme not found)"
    return
  fi

  local theme base dst
  for theme in Win11 Win11-dark; do
    base="${ICONS_DIR}/${theme}"
    [ -d "${base}" ] || continue

    for dst in places/24/start-here-kde.svg \
               places/22/start-here-kde.svg \
               places/22/start-here-kde-plasma.svg \
               places/scalable/start-here-kde.svg \
               places/symbolic/start-here-kde-symbolic.svg \
               places/scalable/start-here-kde-symbolic.svg; do
      [ -d "$(dirname "${base}/${dst}")" ] || continue
      cp -f "${logo}" "${base}/${dst}"
    done

    if command -v gtk-update-icon-cache >/dev/null 2>&1; then
      gtk-update-icon-cache -f -t "${base}" >/dev/null 2>&1
    fi
  done
  echo "  - start button icon patched"
}

# Kvantum picks its concrete theme from kvantum.kvconfig, separate from
# widgetStyle=kvantum. Without this the engine keeps whatever theme was
# selected previously (or none), so Qt apps look unstyled.
configure_kvantum() {
  local target_home=""

  if [ "$UID" -eq "$ROOT_UID" ]; then
    if [ -n "${SUDO_USER}" ]; then
      target_home=$(getent passwd "${SUDO_USER}" | cut -d: -f6)
    fi
  else
    target_home="${HOME}"
  fi

  [ -n "${target_home}" ] || return

  local rc="${target_home}/.config/Kvantum/kvantum.kvconfig"
  mkdir -p "$(dirname "${rc}")"
  if ! grep -q '^theme=' "${rc}" 2>/dev/null; then
    printf '[General]\ntheme=Win11OS-dark\n' > "${rc}"
  fi

  if [ "$UID" -eq "$ROOT_UID" ] && [ -n "${SUDO_USER}" ]; then
    chown -R "${SUDO_USER}": "${target_home}/.config/Kvantum"
  fi
}

echo "Installing '${THEME_NAME} kde themes'..."

install "${name:-${THEME_NAME}}"
install_dependencies
patch_start_icons
configure_kvantum

if command -v kbuildsycoca6 >/dev/null 2>&1 && [ "$UID" -ne "$ROOT_UID" ]; then
  kbuildsycoca6 --noincremental >/dev/null 2>&1
fi

echo "Install finished..."
echo
echo "Apply the theme with:"
echo "  plasma-apply-lookandfeel -a com.github.yeyushengfan258.Win11OS-dark"
echo "  plasma-apply-colorscheme Win11OSDark"
echo "  systemctl --user restart plasma-plasmashell   # re-read the desktop theme"
echo
echo "The global theme ships a Windows 11 style taskbar layout. When applying it"
echo "from System Settings, tick \"Use default layout\" to get the panel with"
echo "start menu, centred task buttons, system tray and clock."
