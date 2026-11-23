#!/bin/sh
# Собирает tar-образ, который RouterOS ставит через /container/add file=
set -e
VER="${1:-1.11.9}"
ROOT=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
cd "$ROOT"
curl -fsSL -o "sing-box-${VER}-linux-armv5.tar.gz" \
  "https://github.com/SagerNet/sing-box/releases/download/v${VER}/sing-box-${VER}-linux-armv5.tar.gz"
rm -rf "sing-box-${VER}-linux-armv5"
tar -xzf "sing-box-${VER}-linux-armv5.tar.gz"
cp "sing-box-${VER}-linux-armv5/sing-box" sing-box
chmod 755 sing-box
docker buildx build --platform linux/arm/v5 \
  -t "kox-singbox:${VER}-armv5" \
  --output "type=docker,dest=sing-box-${VER}-armv5.tar" \
  "$ROOT"
rm -f sing-box
echo "sing-box-${VER}-armv5.tar"
