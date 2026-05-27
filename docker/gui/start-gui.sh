#!/usr/bin/env bash
set -euo pipefail

DISPLAY_NUM="${DISPLAY:-:99}"
RESOLUTION="${RESOLUTION:-1600x900x24}"
VNC_PORT="${VNC_PORT:-5900}"
NOVNC_PORT="${NOVNC_PORT:-6080}"

export DISPLAY="${DISPLAY_NUM}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-/cache}"

mkdir -p /cache /workspace/output /tmp/.X11-unix

Xvfb "${DISPLAY}" -screen 0 "${RESOLUTION}" -ac +extension GLX +render -noreset &
XVFB_PID=$!

fluxbox >/tmp/fluxbox.log 2>&1 &
FLUXBOX_PID=$!

x11vnc -display "${DISPLAY}" -rfbport "${VNC_PORT}" -forever -shared -nopw -xkb >/tmp/x11vnc.log 2>&1 &
X11VNC_PID=$!

websockify --web /usr/share/novnc "${NOVNC_PORT}" "localhost:${VNC_PORT}" >/tmp/websockify.log 2>&1 &
WEBSOCKIFY_PID=$!

cleanup() {
  kill "${WEBSOCKIFY_PID}" "${X11VNC_PID}" "${FLUXBOX_PID}" "${XVFB_PID}" >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM

echo "noVNC available at http://localhost:${NOVNC_PORT}/vnc.html?autoconnect=1"

/usr/local/bin/arnis "$@"
