#!/bin/bash
set -euo pipefail

# Run from the ImmortalWrt source tree after updating feeds.
git clone --depth=1 https://github.com/ophub/luci-app-amlogic clone/amlogic
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall clone/passwall
git clone --depth=1 https://github.com/vernesong/OpenClash clone/openclash

rm -rf feeds/luci/applications/luci-app-daed \
  feeds/luci/applications/luci-app-podman \
  feeds/luci/applications/luci-app-passwall \
  feeds/luci/applications/luci-app-openclash \
  feeds/luci/applications/luci-app-amlogic
cp -a clone/amlogic/luci-app-amlogic clone/passwall/luci-app-passwall \
  clone/openclash/luci-app-openclash feeds/luci/applications/

# Include the official ARM64 Meta core for first boot.
core_commit=$(git ls-remote https://github.com/vernesong/OpenClash.git refs/heads/core | awk '{print $1}')
[[ "$core_commit" =~ ^[0-9a-f]{40}$ ]]
curl --fail --location --retry 5 \
  "https://raw.githubusercontent.com/vernesong/OpenClash/$core_commit/master/meta/clash-linux-arm64.tar.gz" \
  -o clone/clash-meta.tar.gz
mkdir -p clone/core files/etc/openclash/core
tar -xzf clone/clash-meta.tar.gz -C clone/core
install -m 0755 clone/core/clash files/etc/openclash/core/clash_meta
file files/etc/openclash/core/clash_meta | grep -q 'ARM aarch64'

{
  echo "ImmortalWrt $(git rev-parse HEAD)"
  for package in amlogic passwall openclash; do
    echo "$package $(git -C "clone/$package" rev-parse HEAD)"
  done
  echo "OpenClash-core $core_commit"
  sha256sum files/etc/openclash/core/clash_meta
} > build-sources.txt

sed -i '/luci-app-attendedsysupgrade/d' feeds/luci/collections/luci/Makefile
sed -i 's/GO_ARM64:=v8\.0$/GO_ARM64:=v8.0,crypto/' feeds/packages/lang/golang/golang-values.mk
rm -rf clone
