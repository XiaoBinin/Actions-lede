#!/bin/bash

PATCH_DIR="../patches/r1pluslts"
TARGET_DIR="target/linux/rockchip/files/arch/arm64/boot/dts/rockchip"
TARGET_FILES=(
  "rk3328-orangepi-r1-plus.dts"
  "rk3328-orangepi-r1-plus.dtsi"
  "rk3328-orangepi-r1-plus-lts.dts"
)

# 移动文件
# if [ -d "$PATCH_DIR" ]; then
#   echo "🔄 正在移动补丁文件..."
#   mv "$PATCH_DIR"/* "$TARGET_DIR"
# else
#   echo "❌ 源目录不存在：$PATCH_DIR"
#   exit 1
# fi

# 检查每个目标文件是否存在
all_ok=true
for file in "${TARGET_FILES[@]}"; do
  if [ -f "$TARGET_DIR/$file" ]; then
    echo "✅ $file 移动成功"
  else
    echo "❌ $file 移动失败"
    all_ok=false
    exit 1
  fi
done

# # 自动删除 tools/ninja/Makefile 中的 --no-rebuild 参数
# MAKEFILE="tools/ninja/Makefile"

# # 检查文件是否存在
# if [ ! -f "$MAKEFILE" ]; then
#     echo "错误：找不到文件 $MAKEFILE"
#     exit 1
# fi

# # 删除 --no-rebuild 参数
# sed -i 's/--no-rebuild//g' "$MAKEFILE"

# echo "已从 $MAKEFILE 中删除 '--no-rebuild' 参数。"

# 最终判断
if [ "$all_ok" = true ]; then
  echo "🎉 所有文件均已成功移动"
  exit 0
else
  echo "🚨 有文件未成功移动"
  exit 1
fi
