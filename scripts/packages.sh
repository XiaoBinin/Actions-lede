#!/bin/bash

# 删除feeds中的插件
rm -rf ./feeds/packages/net/{geoview,chinadns-ng,hysteria,mosdns,v2ray-geodata,lucky}
rm -rf ./feeds/packages/net/{shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev}
rm -rf ./feeds/packages/net/{sing-box,v2ray-geodata,v2ray-plugin,xray-core,smartdns}

rm -rf ./feeds/luci/applications/{luci-app-passwall,luci-app-passwall2,luci-app-openclash,luci-app-homeproxy}
rm -rf ./feeds/luci/applications/{luci-app-lucky,luci-app-smartdns,luci-app-timecontrol,luci-app-mosdns}
rm -rf ./feeds/luci/applications/{luci-app-nikki,luci-app-momo,luci-app-daed}

# 克隆依赖插件
git clone --depth 1 https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git package/pwpage
# git clone --depth 1 https://github.com/sbwml/packages_lang_golang -b 25.x feeds/packages/lang/golang


# 克隆的源码放在small文件夹
mkdir package/small
pushd package/small

# luci-theme-aurora
git clone -b master --depth 1 https://github.com/eamonxg/luci-theme-aurora.git

# luci-app-nft-timecontrol
git clone -b main --depth 1 https://github.com/sirpdboy/luci-app-timecontrol.git

# adguardhome
# git clone -b 2024.09.05 --depth 1 https://github.com/XiaoBinin/luci-app-adguardhome.git

# homeproxy
git clone -b master --depth 1 https://github.com/immortalwrt/homeproxy.git

# lucky
git clone -b main --depth 1 https://github.com/gdy666/luci-app-lucky.git

# smartdns
git clone -b master --depth 1 https://github.com/pymumu/luci-app-smartdns.git
git clone -b master --depth 1 https://github.com/pymumu/smartdns.git

# ssrp
# git clone -b master --depth 1 https://github.com/fw876/helloworld.git

# VIKINGYFY/packages
git clone -b main --depth 1 https://github.com/VIKINGYFY/packages.git

# passwall
git clone -b main --depth 1 https://github.com/Openwrt-Passwall/openwrt-passwall.git

# passwall2
git clone -b main --depth 1 https://github.com/Openwrt-Passwall/openwrt-passwall2.git

# mosdns
git clone -b v5 --depth 1 https://github.com/sbwml/luci-app-mosdns.git

# luci-app-netspeedtest
git clone -b master --depth 1 https://github.com/sirpdboy/luci-app-netspeedtest.git

# openclash
git clone -b master --depth 1 https://github.com/vernesong/OpenClash.git

# OpenWrt-nikki
git clone -b main --depth 1 https://github.com/nikkinikki-org/OpenWrt-nikki.git

# OpenWrt-momo
git clone -b main --depth 1 https://github.com/nikkinikki-org/OpenWrt-momo.git

# daed
git clone -b master --depth 1 https://github.com/QiuSimons/luci-app-daed.git

#modem
# git clone -b main --depth 1 https://github.com/FUjr/modem_feeds.git

popd

echo "packages executed successfully!"
