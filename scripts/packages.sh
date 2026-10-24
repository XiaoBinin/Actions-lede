#!/usr/bin/env bash
#
# 处理 feeds 里的插件，并克隆需要覆盖/新增的第三方插件
# 必须在 openwrt 源码根目录执行（build.yml 已保证）
#
set -euo pipefail

clone() {
  local url="$1" dir="$2"
  shift 2
  echo "==> clone ${url} -> ${dir}"
  git clone --depth 1 "$@" "$url" "$dir"
}

echo "==> 删除 feeds 中被覆盖的插件"
rm -rf feeds/packages/net/{geoview,chinadns-ng,hysteria,mosdns,lucky}
rm -rf feeds/packages/net/{shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev}
rm -rf feeds/packages/net/{sing-box,v2ray-geodata,v2ray-plugin,xray-core,smartdns}
rm -rf feeds/luci/applications/{luci-app-passwall,luci-app-passwall2,luci-app-openclash,luci-app-homeproxy}
rm -rf feeds/luci/applications/{luci-app-lucky,luci-app-smartdns,luci-app-timecontrol,luci-app-mosdns}
rm -rf feeds/luci/applications/{luci-app-nikki,luci-app-momo,luci-app-daed}

echo "==> 克隆依赖插件"
# passwall 的依赖包（xray-core / sing-box / hysteria / geoview ...）
clone https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git package/pwpage

mkdir -p package/small
pushd package/small > /dev/null

# 主题
clone https://github.com/eamonxg/luci-theme-aurora.git luci-theme-aurora -b master
# 定时控制
clone https://github.com/sirpdboy/luci-app-timecontrol.git luci-app-timecontrol -b main
# homeproxy（immortalwrt 版本，规则文件由 scripts/homeproxy.sh 在后面补）
clone https://github.com/immortalwrt/homeproxy.git homeproxy -b master
# lucky
clone https://github.com/gdy666/luci-app-lucky.git luci-app-lucky -b main
# smartdns
clone https://github.com/pymumu/luci-app-smartdns.git luci-app-smartdns -b master
clone https://github.com/pymumu/smartdns.git smartdns -b master
# VIKINGYFY/packages（一堆 luci 依赖）
clone https://github.com/VIKINGYFY/packages.git VIKINGYFY-packages -b main
# passwall / passwall2
clone https://github.com/Openwrt-Passwall/openwrt-passwall.git luci-app-passwall -b main
clone https://github.com/Openwrt-Passwall/openwrt-passwall2.git luci-app-passwall2 -b main
# mosdns
clone https://github.com/sbwml/luci-app-mosdns.git luci-app-mosdns -b v5
# 网络测速
clone https://github.com/muink/luci-app-netspeedtest.git luci-app-netspeedtest -b master
# openclash
clone https://github.com/vernesong/OpenClash.git OpenClash -b master
# 透明代理系
clone https://github.com/nikkinikki-org/OpenWrt-nikki.git luci-app-nikki -b main
clone https://github.com/nikkinikki-org/OpenWrt-momo.git luci-app-momo -b main
# 流量监控（luci 前端 + bandix 核心包；核心是预编译二进制，按架构从 release 下载）
clone https://github.com/timsaya/luci-app-bandix.git luci-app-bandix -b main
clone https://github.com/timsaya/openwrt-bandix.git openwrt-bandix -b main
# 温度显示（状态页）
clone https://github.com/gSpotx2f/luci-app-temp-status.git luci-app-temp-status -b master
# 网盘（alist 的继任者，取代已失效的 aliyundrive-webdav）
clone https://github.com/sbwml/luci-app-openlist2.git luci-app-openlist2 -b main

# smartdns 的 OpenWrt Makefile 里 include 的是 feed 内的相对路径，
# lede 的 rust 包位置不同，改成从 TOPDIR 开始的绝对路径
SMARTDNS_MK="smartdns/package/openwrt/Makefile"
if [ -f "$SMARTDNS_MK" ]; then
  sed -i 's@include ../../lang/rust/rust-package.mk@include $(TOPDIR)/feeds/packages/lang/rust/rust-package.mk@g' "$SMARTDNS_MK"
  if grep -q 'TOPDIR)/feeds/packages/lang/rust' "$SMARTDNS_MK"; then
    echo "    smartdns: rust-package.mk 路径已改为 TOPDIR 绝对路径"
  else
    echo "::warning::smartdns: Makefile 里没找到预期的 include 行，可能上游已经改过"
  fi
else
  echo "::warning::${SMARTDNS_MK} 不存在，跳过 smartdns 的 include 修正"
fi

popd > /dev/null

echo "==> 清理悬空软链（feeds 目录已删除、又没有补回来的那些包）"
if [ -d package/feeds ]; then
  find package/feeds -xtype l -delete
  echo "悬空软链数量: $(find package/feeds -xtype l 2>/dev/null | wc -l)"
fi

echo "✅ packages.sh 完成"
