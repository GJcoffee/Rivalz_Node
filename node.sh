#!/bin/bash

# 更新系统并安装依赖
echo "更新系统并安装依赖..."
apt update && apt install -y sudo curl zip expect || { echo "依赖安装失败"; exit 1; }

# 安装 fnm (Node.js 版本管理工具)
if ! command -v node &> /dev/null; then
  echo "安装 nodejs..."
  curl -sL https://deb.nodesource.com/setup_22.x | sudo -E bash -
  apt install nodejs -y
  node -v
  npm -v
fi
node -v
npm -v
npm i -g rivalz-node-cli


# 动态获取本地 IP 地址
echo "获取本地 IP 地址..."
local_ip=$(curl -s ifconfig.me)

# 从接口动态获取钱包地址
server_host="http://111.9.18.211:19999"
get_nexus_api="$server_host/rivalz?ip=$local_ip"
echo "从接口获取钱包地址: $get_nexus_api"
wallet_address=$(curl -s "$get_nexus_api")
# 检查钱包地址是否为空
if [[ -z "$wallet_address" ]]; then
  echo "无法获取钱包地址，请检查接口或本地 IP 设置"
  exit 1
fi

echo "获取到的钱包地址为: $wallet_address"

# 创建 expect 脚本
echo "创建自动化 expect 脚本..."
cat > auto_run_rivalz.exp << EOF
#!/usr/bin/expect
set timeout -1
spawn rivalz run

expect "Enter wallet address (EVM):"
send "$wallet_address\r"

expect "Select drive you want to use:"
send "overlay\r"

expect "Enter Disk size of overlay (SSD) you want to use"
send "10\r"

expect eof
EOF

# 设置 expect 脚本执行权限
chmod +x auto_run_rivalz.exp

# 运行 expect 脚本
echo "运行自动化脚本..."
./auto_run_rivalz.exp || { echo "自动化脚本运行失败"; exit 1; }

echo "脚本执行完成！"
