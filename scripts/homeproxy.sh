#!/usr/bin/env bash
#
# 预置 homeproxy 的规则文件，并把默认 DNS 改成 DoH
#
set -euo pipefail

HP_RULE="surge"
HP_PATH="root/etc/homeproxy"

# 依次尝试：packages.sh 克隆下来的那份 -> feeds 里的那份
CANDIDATES=(
  "package/small/homeproxy/luci-app-homeproxy"
  "package/small/homeproxy"
  "feeds/luci/applications/luci-app-homeproxy"
)

HP_DIR=""
for d in "${CANDIDATES[@]}"; do
  if [ -f "${d}/root/etc/config/homeproxy" ]; then
    HP_DIR="$d"
    break
  fi
done

if [ -z "$HP_DIR" ]; then
  # 不是致命错误：可能只是 packages.sh 里删掉了 homeproxy
  echo "::warning::没找到 homeproxy 包目录，跳过规则预置（Packages 里没选 homeproxy？）"
  exit 0
fi

echo "==> homeproxy 目录: ${HP_DIR}"
RES_DIR="${HP_DIR}/${HP_PATH}/resources"
# 下面会 pushd 进 surge/ 目录，相对路径会指错地方，先转成绝对路径
RES_DIR_ABS="$(pwd)/${RES_DIR}"

echo "==> 拉取 Loyalsoldier/surge-rules（release 分支）"
rm -rf "./${HP_RULE}"
git clone -q --depth=1 --single-branch --branch release \
  "https://github.com/Loyalsoldier/surge-rules.git" "./${HP_RULE}"

pushd "./${HP_RULE}" > /dev/null

# 上游文件改名的话，后面的 awk/sed 会在 set -e 下直接失败，这里提前报清楚
for f in cncidr.txt direct.txt gfw.txt; do
  if [ ! -f "$f" ]; then
    echo "::error::surge-rules(release) 里没有 ${f}，上游结构变了"
    exit 1
  fi
done

RES_VER=$(git log -1 --pretty=format:'%s' | grep -o "[0-9]*" | head -n 1 || true)
RES_VER="${RES_VER:-0}"
echo "${RES_VER}" | tee china_ip4.ver china_ip6.ver china_list.ver gfw_list.ver > /dev/null

awk -F, '/^IP-CIDR,/{print $2 > "china_ip4.txt"} /^IP-CIDR6,/{print $2 > "china_ip6.txt"}' cncidr.txt
sed 's/^\.//g' direct.txt > china_list.txt
sed 's/^\.//g' gfw.txt > gfw_list.txt

mkdir -p "$RES_DIR_ABS"
for f in china_ip4.ver china_ip6.ver china_list.ver gfw_list.ver \
         china_ip4.txt china_ip6.txt china_list.txt gfw_list.txt; do
  if [ -f "$f" ]; then
    mv -f "$f" "$RES_DIR_ABS/"
  fi
done

popd > /dev/null
rm -rf "./${HP_RULE}"

# 规则文件没生成就别继续了：宁可报错，也不要发一个规则是空的固件
if compgen -G "${RES_DIR_ABS}/*" > /dev/null; then
  echo "✅ homeproxy 规则已更新（版本 ${RES_VER}，$(find "$RES_DIR_ABS" -maxdepth 1 -type f | wc -l) 个文件）"
else
  echo "::error::${RES_DIR_ABS} 里没有生成规则文件，检查 surge-rules 的文件名是否变了"
  exit 1
fi

# 默认 DNS -> DoH
DNS_CONFIG_FILE="${HP_DIR}/root/etc/config/homeproxy"
if [ -f "$DNS_CONFIG_FILE" ]; then
  sed -i "s|option dns_server '8.8.8.8'|option dns_server 'https://94.140.14.140/dns-query'|g" "$DNS_CONFIG_FILE"
  sed -i "s|option china_dns_server '223.5.5.5'|option china_dns_server 'https://223.5.5.5/dns-query'|g" "$DNS_CONFIG_FILE"
  echo "✅ homeproxy 默认 DNS 已改为 DoH"
else
  echo "::warning::${DNS_CONFIG_FILE} 不存在，DNS 默认值没改"
fi

echo "✅ homeproxy.sh 完成"
