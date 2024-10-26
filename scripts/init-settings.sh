#!/bin/bash

#更改默认地址为192.168.8.1
sed -i 's/192.168.1.1/192.168.8.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.1.1/192.168.8.1/g' package/base-files/luci2/bin/config_generate

#更改design主题为白色
# sed -i 's/dark/light/g' feeds/luci/applications/luci-app-design-config/root/etc/config/design

echo "init-settings executed successfully!"
