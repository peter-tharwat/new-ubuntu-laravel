#!/bin/bash
# Install/enable PHP BCMath on Ubuntu (required by google/protobuf for Analytics API).
# Usage: sudo ./fix-bcmath.sh

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root: sudo $0"
  exit 1
fi

apt-get update

for ver in 8.2 8.3 8.4; do
  if apt-cache show "php${ver}-bcmath" &>/dev/null; then
    echo "Installing php${ver}-bcmath..."
    apt-get install -y "php${ver}-bcmath"
  fi
  if [ -d "/etc/php/${ver}/fpm" ]; then
    systemctl restart "php${ver}-fpm" 2>/dev/null || service "php${ver}-fpm" restart 2>/dev/null || true
  fi
done

echo "Verifying bcmath:"
for bin in php php8.2 php8.3 php8.4; do
  if command -v "$bin" >/dev/null 2>&1; then
    if "$bin" -m | grep -q '^bcmath$'; then
      echo "  OK  $bin"
    else
      echo "  FAIL $bin (bcmath missing)"
    fi
  fi
done

echo "Done."
