#!/usr/bin/env bash
#
# 只给 x86-64 平台用：把 files-x86/ 覆盖进 openwrt/files/
# 必须在 openwrt 源码根目录执行（build.yml 已保证）
#
# 这些文件做的是"x86 小主机插 USB3 千兆网卡 → 自动并入 LAN"：
#   files-x86/usr/sbin/usb-nic-lan                 主逻辑（status / auto / add）
#   files-x86/etc/hotplug.d/net/20-usb-nic-lan     热插拔钩子
#   files-x86/etc/uci-defaults/99-usb-nic-lan      首次开机扫一遍
#
set -euo pipefail

SRC="${GITHUB_WORKSPACE:?GITHUB_WORKSPACE 未设置}/files-x86"
if [ ! -d "$SRC" ]; then
  echo "::error::找不到 ${SRC}"
  exit 1
fi

mkdir -p files
cp -a "$SRC/." files/

# git 在 Windows 上可能丢掉执行位，这里统一补上
chmod 755 files/usr/sbin/usb-nic-lan \
          files/etc/hotplug.d/net/20-usb-nic-lan \
          files/etc/uci-defaults/99-usb-nic-lan

echo "==> 已安装 USB 网卡自动并入 LAN 的脚本（仅 x86）"
ls -l files/usr/sbin/usb-nic-lan files/etc/hotplug.d/net/20-usb-nic-lan files/etc/uci-defaults/99-usb-nic-lan
