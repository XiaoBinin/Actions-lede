#!/bin/bash

# 定义文件路径
FILE="target/linux/mediatek/image/filogic.mk"

# 检查文件是否存在
if [ ! -f "$FILE" ]; then
    echo "错误：文件 $FILE 不存在"
    exit 1
fi

# 执行替换操作， kmod-usb3 后添加 automount
sed -i 's/kmod-usb3/& automount/g' "$FILE"

echo "已成功在 $FILE 中的 kmod-usb3 后添加 automount"
