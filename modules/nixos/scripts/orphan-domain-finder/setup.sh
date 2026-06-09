#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[-]${NC} $1"; }

check_cmd() {
    local cmd="$1"
    if command -v "$cmd" >/dev/null 2>&1; then
        info "$cmd found"
        return 0
    else
        warn "$cmd missing"
        return 1
    fi
}

detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "${ID:-unknown}"
    else
        echo "unknown"
    fi
}

OS_ID="$(detect_os)"

echo
echo "========================================"
echo " Orphan Domain Finder Setup Check"
echo "========================================"
echo
info "Detected OS: $OS_ID"
echo

REQUIRED_TOOLS=(
    python3
)

OPTIONAL_TOOLS=(
    dig
    subfinder
    amass
    httpx
    katana
    dnsgen
)

echo "Required Tools"
echo "--------------"

MISSING_REQUIRED=0
for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! check_cmd "$tool"; then
        MISSING_REQUIRED=1
    fi
done

echo
echo "Optional Tools"
echo "--------------"

for tool in "${OPTIONAL_TOOLS[@]}"; do
    check_cmd "$tool" || true
done

echo
echo "Python Environment"
echo "------------------"

if [[ ! -d "venv" ]]; then
    if check_cmd python3; then
        info "Creating Python virtual environment"
        python3 -m venv --copies venv|| warn "Could not create venv. You may need python3-venv on Debian/Kali."
    fi
else
    info "venv already exists"
fi

if [[ -d "venv" ]]; then
    # shellcheck disable=SC1091
    if [[ -f "venv/bin/activate" ]]; then
    source venv/bin/activate
else
    warn "venv was not created successfully, skipping activation"
fi

    if [[ -f "requirements.txt" ]]; then
        info "Installing Python requirements"
        python -m pip install --upgrade pip
        python -m pip install -r requirements.txt
    else
        warn "requirements.txt not found"
    fi
fi

echo
echo "Install Help"
echo "------------"

case "$OS_ID" in
    nixos)
        cat <<'EOF'
NixOS temporary shell:

nix-shell -p \
  python3 \
  python3Packages.pip \
  python3Packages.virtualenv \
  dnsutils \
  amass \
  subfinder \
  httpx \
  katana \
  go

Then install dnsgen inside the venv:

source venv/bin/activate
pip install dnsgen

For a permanent NixOS config, add something like:

environment.systemPackages = with pkgs; [
  python3
  python3Packages.pip
  python3Packages.virtualenv
  dnsutils
  amass
  subfinder
  httpx
  katana
  go
];

EOF
        ;;

    debian|kali|ubuntu)
        cat <<'EOF'
Debian/Kali install:

sudo apt update
sudo apt install -y \
  python3 \
  python3-pip \
  python3-venv \
  dnsutils \
  amass \
  golang-go

ProjectDiscovery tools:

go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install github.com/projectdiscovery/httpx/cmd/httpx@latest
go install github.com/projectdiscovery/katana/cmd/katana@latest

Make sure Go tools are in PATH:

export PATH="$PATH:$HOME/go/bin"

Python tool:

source venv/bin/activate
pip install dnsgen

EOF
        ;;

    *)
        cat <<'EOF'
Unknown OS.

Manually install:

- python3
- pip
- venv
- dig / dnsutils
- amass
- subfinder
- httpx
- katana
- dnsgen

EOF
        ;;
esac

echo
echo "Feature Summary"
echo "---------------"

command -v dig >/dev/null 2>&1       && echo "✓ DNS record discovery" || echo "✗ DNS record discovery unavailable"
command -v subfinder >/dev/null 2>&1 && echo "✓ subfinder passive discovery" || echo "✗ subfinder unavailable"
command -v amass >/dev/null 2>&1     && echo "✓ amass passive discovery" || echo "✗ amass unavailable"
command -v httpx >/dev/null 2>&1     && echo "✓ httpx web validation" || echo "✗ httpx unavailable"
command -v katana >/dev/null 2>&1    && echo "✓ katana crawling" || echo "✗ katana unavailable"
command -v dnsgen >/dev/null 2>&1    && echo "✓ dnsgen permutations" || echo "✗ dnsgen unavailable"

echo
if [[ "$MISSING_REQUIRED" -eq 1 ]]; then
    err "Required tools are missing."
    exit 1
else
    info "Setup check complete"
fi

echo
echo "Example run:"
echo "./orphan-domain-finder.py -d example.com --subfinder --amass --httpx --dnsgen"
echo
