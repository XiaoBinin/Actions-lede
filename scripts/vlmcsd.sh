#!/usr/bin/env bash
#
# 用 patches/vlmcsd 覆盖 feeds 里的 vlmcsd（lede 自带版本功能不全）
# 必须在 openwrt 源码根目录执行（build.yml 已保证）
#
set -euo pipefail

SRC="${GITHUB_WORKSPACE:?GITHUB_WORKSPACE 未设置}/patches/vlmcsd"
DST="feeds/packages/net/vlmcsd"

if [ ! -d "$SRC" ]; then
  echo "::error::找不到 ${SRC}"
  exit 1
fi

echo "==> 替换 feeds/packages/net/vlmcsd"
rm -rf "$DST"
cp -r "$SRC" "$DST"

if [ ! -f "$DST/Makefile" ]; then
  echo "::error::vlmcsd 替换失败（Makefile 不存在）"
  exit 1
fi

echo "    vlmcsd：$(sed -n 's/^PKG_RELEASE:=//p' "$DST/Makefile" | head -n 1)（PKG_RELEASE）"
echo "✅ vlmcsd.sh 完成"
