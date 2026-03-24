#!/usr/bin/env bash
set -euo pipefail

BINARY_NAME="silo"
DESKTOP_FILE="com.nofaff.Silo.desktop"
INSTALL_DIR="${HOME}/.local/bin"
DESKTOP_DIR="${HOME}/.local/share/applications"
HOST_LIB_DIR="${HOME}/.local/lib/silo"
FIREFOX_NMH_DIR="${HOME}/.mozilla/native-messaging-hosts"

echo "Installing Silo..."

# Copy binary
mkdir -p "${INSTALL_DIR}"
cp "${BINARY_NAME}" "${INSTALL_DIR}/${BINARY_NAME}"
chmod +x "${INSTALL_DIR}/${BINARY_NAME}"

# Install .desktop file, substituting the correct binary path
mkdir -p "${DESKTOP_DIR}"
# find the .desktop file (works from both repo root and release tarball)
if [ -f "data/${DESKTOP_FILE}" ]; then
    DESKTOP_SRC="data/${DESKTOP_FILE}"
elif [ -f "${DESKTOP_FILE}" ]; then
    DESKTOP_SRC="${DESKTOP_FILE}"
else
    echo "Error: could not find ${DESKTOP_FILE}"
    exit 1
fi
sed "s|^Exec=silo |Exec=${INSTALL_DIR}/${BINARY_NAME} |" \
    "${DESKTOP_SRC}" > "${DESKTOP_DIR}/${DESKTOP_FILE}"

# Install icon
ICON_SRC="data/icons/hicolor/128x128/apps/com.nofaff.Silo.png"
ICON_DIR="${HOME}/.local/share/icons/hicolor/128x128/apps"
if [ -f "${ICON_SRC}" ]; then
    mkdir -p "${ICON_DIR}"
    cp "${ICON_SRC}" "${ICON_DIR}/com.nofaff.Silo.png"
    gtk-update-icon-cache "${HOME}/.local/share/icons/hicolor" 2>/dev/null || true
fi

# Update desktop database
update-desktop-database "${DESKTOP_DIR}" 2>/dev/null || true

# Install native messaging host for browser extensions
HOST_SRC="native-host/silo-host.py"
FIREFOX_MANIFEST_SRC="native-host/com.nofaff.silo.firefox.json"
if [ -f "${HOST_SRC}" ] && [ -f "${FIREFOX_MANIFEST_SRC}" ]; then
    mkdir -p "${HOST_LIB_DIR}"
    cp "${HOST_SRC}" "${HOST_LIB_DIR}/silo-host.py"
    chmod +x "${HOST_LIB_DIR}/silo-host.py"

    mkdir -p "${FIREFOX_NMH_DIR}"
    sed "s|SILO_HOST_PATH|${HOST_LIB_DIR}/silo-host.py|" \
        "${FIREFOX_MANIFEST_SRC}" > "${FIREFOX_NMH_DIR}/com.nofaff.silo.json"
    echo "Installed native messaging host for Firefox"
fi

echo "Installed to ${INSTALL_DIR}/${BINARY_NAME}"

# Check if the install directory is in PATH
case ":${PATH}:" in
    *":${INSTALL_DIR}:"*) ;;
    *) echo ""
       echo "Warning: ${INSTALL_DIR} is not in your PATH."
       echo "Add it to your shell profile, or run Silo using the full path:"
       echo "  ${INSTALL_DIR}/${BINARY_NAME}"
       echo "" ;;
esac

echo ""
echo "To set Silo as your default browser, run:"
echo "  silo"
echo ""
echo "Or set it manually:"
echo "  xdg-settings set default-web-browser ${DESKTOP_FILE}"
