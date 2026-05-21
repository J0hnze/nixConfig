#!/usr/bin/env bash

set -e

# =========================
# CONFIG
# =========================
BASE_DIR="/tmp/firefox/profiles"
CERT_PATH="$HOME/certs/burp-ca.der"
FIREFOX_BIN="$(which firefox)"
TARGET_URL="https://duckduckgo.com/"

# =========================
# CHECKS
# =========================
echo "[+] Checking dependencies..."

if ! command -v certutil >/dev/null 2>&1; then
  echo "[-] certutil not found. Install nssTools in NixOS."
  exit 1
fi

if [ ! -f "$CERT_PATH" ]; then
  echo "[-] Burp cert not found at $CERT_PATH"
  exit 1
fi

echo "[+] Resetting profiles..."
rm -rf "$BASE_DIR"
mkdir -p "$BASE_DIR"/{green,blue,red}

# =========================
# FUNCTIONS
# =========================

create_profile() {
  NAME=$1
  UA=$2
  COLOR=$3
  DIR="$BASE_DIR/$NAME"

  echo "[+] Creating profile: $NAME"

  mkdir -p "$DIR/chrome"

  # Bootstrap profile (creates cert DB)
  $FIREFOX_BIN --headless --profile "$DIR" --no-remote >/dev/null 2>&1 &
  sleep 2
  pkill -f "$DIR" 2>/dev/null || true

  # =========================
  # Proxy + UA config
  # =========================
  cat > "$DIR/user.js" <<EOF
user_pref("network.proxy.type", 1);
user_pref("network.proxy.http", "127.0.0.1");
user_pref("network.proxy.http_port", 8080);
user_pref("network.proxy.ssl", "127.0.0.1");
user_pref("network.proxy.ssl_port", 8080);
user_pref("network.proxy.share_proxy_settings", true);
user_pref("network.proxy.no_proxies_on", "");
user_pref("network.proxy.allow_hijacking_localhost", true);
user_pref("general.useragent.override", "$UA");
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
EOF

  # =========================
  # Import Burp CA
  # =========================
  echo "[+] Importing Burp CA into $NAME"

  certutil -A \
    -n "Burp CA" \
    -t "C,," \
    -i "$CERT_PATH" \
    -d sql:"$DIR"

  # =========================
  # Firefox UI Theme (userChrome.css)
  # =========================
  case "$COLOR" in
    green)
      HEX="#1f7a1f"
      LABEL="USER (GREEN)"
      ;;
    blue)
      HEX="#1f4e7a"
      LABEL="MANAGER (BLUE)"
      ;;
    red)
      HEX="#7a1f1f"
      LABEL="ADMIN (RED)"
      ;;
  esac

  cat > "$DIR/chrome/userChrome.css" <<EOF
/* Toolbar + tabs colour */
#navigator-toolbox,
#TabsToolbar {
  background-color: $HEX !important;
}

/* Toolbar text */
#nav-bar {
  color: white !important;
}

/* Label injected into toolbar */
#nav-bar::before {
  content: "$LABEL";
  font-weight: bold;
  color: white;
  margin-right: 15px;
  padding-left: 8px;
}
EOF

  echo "[+] Profile ready: $NAME"
}

launch_profile() {
  NAME=$1
  DIR="$BASE_DIR/$NAME"

  echo "[+] Launching $NAME"

  $FIREFOX_BIN \
    --no-remote \
    --new-instance \
    --profile "$DIR" \
    "$TARGET_URL" \
    &
}

# =========================
# CREATE PROFILES
# =========================

create_profile "green" "Firefox-Green" "green"
create_profile "blue"  "Firefox-Blue"  "blue"
create_profile "red"   "Firefox-Red"   "red"

# =========================
# LAUNCH
# =========================

launch_profile "green"
launch_profile "blue"
launch_profile "red"

echo "[+] All profiles launched through Burp"