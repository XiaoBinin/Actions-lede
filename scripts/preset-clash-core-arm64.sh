#!/bin/bash
#=================================================
# File name: preset-clash-core.sh
# Usage: <preset-clash-core.sh $platform> | example: <preset-clash-core.sh armv8>
# System Required: Linux
# Version: 1.0
# Lisence: MIT
# Author: SuLingGG
# Blog: https://mlapp.cn
# 参考网址：https://github.com/zzcabc/OpenWrt_Action/blob/11208c3d5160128d22d14318772ec48f1918deb9/script/immortalwrt/diy2.sh
# 插件网址：https://github.com/vernesong/OpenClash
# 内核网址：https://github.com/MetaCubeX/mihomo
# 规则网址：https://github.com/MetaCubeX/meta-rules-dat
#=================================================


# 预置openclash内核
mkdir -p files/etc/openclash/core


# openclash 的 dev内核
CLASH_DEV_URL="https://github.com/vernesong/OpenClash/raw/core/master/dev/clash-linux-arm64.tar.gz"

# openclash 的 TUN内核
CLASH_TUN_VERSION=$(curl -sL https://github.com/vernesong/OpenClash/raw/core/master/core_version | head -n 2 | tail -n 1)
CLASH_TUN_URL="https://github.com/vernesong/OpenClash/raw/core/master/premium/clash-linux-arm64-$CLASH_TUN_VERSION.gz"

# openclash 的 Meta内核版本
# CLASH_META_URL="https://github.com/vernesong/OpenClash/raw/core/master/meta/clash-linux-amd64.tar.gz"



# d大 的 dev内核
# CLASH_DEV_URL=$(curl -sL https://api.github.com/repos/Dreamacro/clash/releases/latest | grep /clash-linux-amd64 | awk -F '"' '{print $4}' | head -n 1)

# d大 的 premium内核
# CLASH_TUN_URL=$(curl -sL https://api.github.com/repos/Dreamacro/clash/releases/tags/premium | grep /clash-linux-amd64-2 | awk -F '"' '{print $4}' | head -n 1)



# Meta内核版本
CLASH_META_URL=$(curl -sL https://api.github.com/repos/MetaCubeX/Clash.Meta/releases/tags/Prerelease-Alpha | grep -o '"browser_download_url": *"[^"]*mihomo-linux-arm64-alpha-[^"]*\.gz"' | awk -F '"' '{print $4}' | head -n 1)

# CLASH_DEV_URL="https://raw.githubusercontent.com/vernesong/OpenClash/master/core-lateset/dev/clash-linux-arm64.tar.gz"
# CLASH_TUN_URL=$(curl -fsSL https://api.github.com/repos/vernesong/OpenClash/contents/core-lateset/premium | grep download_url | grep $1 | awk -F '"' '{print $4}')
# CLASH_META_URL="https://raw.githubusercontent.com/vernesong/OpenClash/master/core-lateset/meta/clash-linux-${1}.tar.gz"


# 给内核解压
wget -qO- $CLASH_DEV_URL | tar xOvz > files/etc/openclash/core/clash
wget -qO- $CLASH_TUN_URL | gunzip -c > files/etc/openclash/core/clash_tun
# wget -qO- $CLASH_META_URL | tar xOvz > files/etc/openclash/core/clash_meta

# wget -qO- $CLASH_DEV_URL | gunzip -c > files/etc/openclash/core/clash
# wget -qO- $CLASH_TUN_URL | gunzip -c > files/etc/openclash/core/clash_tun
wget -qO- $CLASH_META_URL | gunzip -c > files/etc/openclash/core/clash_meta

# 给内核权限
chmod +x files/etc/openclash/core/clash*


# 下载mihomo core需要的文件？
# GeoIP.dat
GEOIP_URL=https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.dat
# GeoSite.dat
GEOSITE_URL=https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat
# Country.mmdb
COUNTRY_FULL_URL=https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/country.mmdb

wget -qO- $GEOIP_URL > files/etc/openclash/GeoIP.dat
wget -qO- $GEOSITE_URL > files/etc/openclash/GeoSite.dat
wget -qO- $COUNTRY_FULL_URL > files/etc/openclash/Country.mmdb

echo "preset-clash-core executed successfully!"
