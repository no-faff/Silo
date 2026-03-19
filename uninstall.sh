#!/usr/bin/env bash
set -euo pipefail

BINARY_NAME="silo"
DESKTOP_FILE="com.nofaff.Silo.desktop"
INSTALL_DIR="${HOME}/.local/bin"
DESKTOP_DIR="${HOME}/.local/share/applications"
CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/silo"
CONFIG_FILE="${CONFIG_DIR}/config.json"

echo "Uninstalling Silo..."

# restore previous default browser if Silo is currently the default
current=$(xdg-settings get default-web-browser 2>/dev/null || true)
if [ "${current}" = "${DESKTOP_FILE}" ]; then
    previous=""
    if [ -f "${CONFIG_FILE}" ]; then
        # pull previous_default_browser from config without needing jq
        previous=$(grep -o '"previous_default_browser"[[:space:]]*:[[:space:]]*"[^"]*"' "${CONFIG_FILE}" \
            | head -1 | sed 's/.*:.*"\(.*\)"/\1/')
    fi

    if [ -n "${previous}" ]; then
        echo "Restoring default browser to ${previous}"
        xdg-settings set default-web-browser "${previous}" 2>/dev/null || true
    else
        echo "No previous default browser recorded."
        echo "Set one manually: xdg-settings set default-web-browser <name>.desktop"
    fi
fi

rm -f "${INSTALL_DIR}/${BINARY_NAME}"
rm -f "${DESKTOP_DIR}/${DESKTOP_FILE}"
update-desktop-database "${DESKTOP_DIR}" 2>/dev/null || true

# ask before deleting config
if [ -d "${CONFIG_DIR}" ]; then
    read -rp "Delete config and rules in ${CONFIG_DIR}? [y/N] " answer
    if [[ "${answer}" =~ ^[Yy]$ ]]; then
        rm -rf "${CONFIG_DIR}"
        echo "Config deleted."
    else
        echo "Config kept."
    fi
fi

echo "Silo uninstalled."
