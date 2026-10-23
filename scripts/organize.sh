#!/usr/bin/env bash
#
# 整理产物：清杂项 -> 按平台重命名 -> 重算校验和 -> 生成 Release 说明
# 用法: organize.sh <platform>
#
# 依赖环境变量: GITHUB_WORKSPACE / GITHUB_ENV / BRANCH / WRT_HASH / KERNEL_VERSION(可选)
#
# 与原 workflow 的区别（这些逻辑原来散在 6 个 yml 的"整理文件/固件重命名"步骤里）：
#   * 产物目录不是恰好一个就直接报错（原来 `cd openwrt/bin/targets/*/*` 在多个目录时行为不确定）
#   * 重命名后**重算 sha256sums**。原来只删不改，重命名完 sha256sums 里还是旧文件名，
#     用户照着校验必然对不上
#   * 各平台"删哪些文件"集中在一处，仍然保留原仓库的取舍（见下面的 case）
#
set -euo pipefail
shopt -s nullglob

PLATFORM="${1:?用法: organize.sh <platform>}"
: "${GITHUB_ENV:?GITHUB_ENV 未设置}"
: "${GITHUB_WORKSPACE:?GITHUB_WORKSPACE 未设置}"
: "${BRANCH:?BRANCH 未设置}"
RUN_NUMBER="${GITHUB_RUN_NUMBER:-0}"

TARGET_DIRS=(openwrt/bin/targets/*/*/)
if [ "${#TARGET_DIRS[@]}" -ne 1 ]; then
  echo "::error::期望恰好一个产物目录，实际 ${#TARGET_DIRS[@]} 个：${TARGET_DIRS[*]}" >&2
  exit 1
fi
cd "${TARGET_DIRS[0]}"
echo "==> 产物目录: $PWD"

# 1. 不需要上传的东西
# 用 find -delete 而不是 rm ./*.json：开了 nullglob 又恰好没匹配时，
# `rm -f` 会变成"没有操作数"直接报错（set -e 下就是流水线失败）。
find . -maxdepth 1 -type f \
  \( -name '*.buildinfo' -o -name '*.json' -o -name '*.manifest' -o -name 'sha256sums' \) -delete
rm -rf ./packages

# 2. 按平台决定删哪些文件、去掉哪个文件名前缀
PREFIX=""
case "$PLATFORM" in
  x86-64)
    # 只要 img.gz / vmdk 之类的成品镜像
    find . -maxdepth 1 -type f -name '*.bin' -delete
    ;;
  allwinner)
    PREFIX="sunxi-cortexa53-"
    ;;
  rockchip|r1pluslts)
    find . -maxdepth 1 -type f -name '*.bin' -delete
    PREFIX="rockchip-armv8-"
    ;;
  mt7621)
    PREFIX="ramips-mt7621-"
    ;;
  filogic)
    # 只删 initramfs 内核。preloader / gpt / bl31-uboot.fip 是首次刷机要用的文件，
    # 体积又很小，必须留着（原 workflow 也是这么删的，这里保持不变）
    find . -maxdepth 1 -type f -name '*kernel.bin' -delete
    PREFIX="mediatek-filogic-"
    ;;
  *)
    echo "::warning::未知平台 ${PLATFORM}，只做清理不做重命名"
    ;;
esac

# 3. 去掉文件名里冗余的平台前缀
if [ -n "$PREFIX" ]; then
  for f in *; do
    [ -f "$f" ] || continue
    case "$f" in
      "$PREFIX"*)
        mv -v -- "$f" "${f#"$PREFIX"}"
        ;;
    esac
  done
fi

# 4. 重命名之后原来的 sha256sums 已经对不上，重算一份
{
  for f in *; do
    [ -f "$f" ] || continue
    if [ "$f" = "sha256sums" ]; then continue; fi
    printf '%s *%s\n' "$(sha256sum -- "$f" | awk '{print $1}')" "$f"
  done
} > sha256sums

echo "FIRMWARE=$PWD" >> "$GITHUB_ENV"

# 5. Release 说明
case "$PLATFORM" in
  x86-64)     TITLE="X86-64 平台" ;;
  allwinner)  TITLE="Allwinner 平台" ;;
  rockchip)   TITLE="Rockchip 平台" ;;
  r1pluslts)  TITLE="香橙派 R1 Plus / R1 Plus LTS（Docker 版）" ;;
  mt7621)     TITLE="ramips MT7621 平台" ;;
  filogic)    TITLE="MTK Filogic 平台" ;;
  *)          TITLE="${PLATFORM} 平台" ;;
esac

case "$PLATFORM" in
  x86-64)    NOTE="写 U 盘或硬盘都行。" ;;
  allwinner) NOTE="能插内存卡的写内存卡，eMMC 的用官方工具写入。" ;;
  rockchip)  NOTE="如出现不稳定，可尝试降低 CPU 频率（已移除 lede 的 991 超频补丁，仍可能个别板子不兼容）。" ;;
  r1pluslts) NOTE="仅适用香橙派 R1 Plus / R1 Plus LTS，已内置 docker。" ;;
  mt7621)    NOTE="先刷好不死 bootloader，再刷 factory.bin，之后用 squashfs-sysupgrade.bin 升级。" ;;
  filogic)   NOTE="首次刷机需要 preloader(bl2) / gpt(部分机型) / bl31-uboot.fip，按机型说明顺序刷。" ;;
  *)         NOTE="" ;;
esac

{
  echo "🎉 ${TITLE}"
  echo
  echo "- 源码分支：\`${BRANCH}\`（${WRT_HASH:-unknown}）"
  if [ -n "${KERNEL_VERSION:-}" ]; then
    echo "- 内核版本：\`${KERNEL_VERSION}\`"
  fi
  echo "- 默认 IP：\`192.168.8.1\`"
  echo "- 构建时间：$(date '+%Y-%m-%d %H:%M %Z')（run #${RUN_NUMBER}）"
  if [ -n "$NOTE" ]; then
    echo
    echo "> ${NOTE}"
  fi
  echo
  echo "> 产物已去掉平台前缀，校验和见 \`sha256sums\`。"
} > "$GITHUB_WORKSPACE/release.txt"

echo "==> 产物清单:"
ls -lh
echo "✅ organize.sh 完成"
