#!/bin/bash

#删除feeds中自带的smartdns
rm -rf ./feeds/packages/net/smartdns

#克隆插件
#smartdns
git clone -b lede https://github.com/pymumu/luci-app-smartdns.git package/lucismartdns
git clone -b master https://github.com/pymumu/smartdns.git package/smartdns
#ssrp
#git clone -b master https://github.com/fw876/helloworld.git package/ssrp
#passwall
git clone -b luci --depth 1 https://github.com/xiaorouji/openwrt-passwall.git package/pw
#git clone -b packages https://github.com/xiaorouji/openwrt-passwall.git package/pwages
#passwall2
git clone -b main https://github.com/xiaorouji/openwrt-passwall2.git package/pw2
#mosdns
git clone -b v5 --depth 1 https://github.com/sbwml/luci-app-mosdns.git package/mosdns
#openclash
git clone -b master --depth 1 https://github.com/vernesong/OpenClash.git package/opclash
