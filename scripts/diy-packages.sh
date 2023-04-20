#删除feeds上的插件
rm -rf ./feeds/packages/net/smartdns
rm -rf ./feeds/packages/net/mosdns
rm -rf ./feeds/luci/applications/luci-app-smartdns


#克隆的源码放在small文件夹
mkdir package/small
pushd package/small

#克隆源码
git clone --depth=1 https://github.com/kenzok8/openwrt-packages.git
rm -rf openwrt-packages/luci-app-mosdns
rm -rf openwrt-packages/mosdns

git clone -b v5 https://github.com/sbwml/luci-app-mosdns.git

popd
