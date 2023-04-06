#!/bin/bash

#创建所需文件夹
mkdir -p package/lean/r8152/patches
mkdir -p target/linux/rockchip/files/drivers/phy/rockchip

#更改默认地址为192.168.8.1
sed -i 's/192.168.1.1/192.168.8.1/g' package/base-files/files/bin/config_generate

#更改r8152默认驱动
sed -i 's/kmod-usb-net-rtl8152/kmod-usb-net-rtl8152-vendor/g' target/linux/rockchip/image/armv8.mk

#添加内核配置
sed -i '$a CONFIG_PHY_ROCKCHIP_INNO_USB3=y' target/linux/rockchip/armv8/config-5.15

#删除feeds中自带的smartdns
#rm -rf ./feeds/packages/net/smartdns

#克隆插件
#smartdns
#git clone -b lede https://github.com/pymumu/luci-app-smartdns.git package/smartdns
#passwall2
#git clone https://github.com/xiaorouji/openwrt-passwall2.git
#openwrt-packages
git clone https://github.com/kenzok8/openwrt-packages.git package/opackages
#wall
git clone https://github.com/kenzok8/wall.git package/wall