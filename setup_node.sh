#!/bin/bash

set -e
set -x

echo "=== Creating 6G swap ==="
fallocate -l 6G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab

echo "=== Installing Golang 1.24.2 ==="
wget https://go.dev/dl/go1.24.2.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.24.2.linux-amd64.tar.gz

# Add Go to PATH if not already present
if ! grep -q "/usr/local/go/bin" ~/.bashrc; then
  echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
fi
export PATH=$PATH:/usr/local/go/bin
go version

echo "=== Installing Ignite CLI ==="
git clone https://github.com/ignite/cli.git
cd cli
git checkout v28.5.3
go install ./ignite/cmd/ignite --no
cd ..
rm -rf cli

# Add go bin to PATH if not already present
if ! grep -q "$HOME/go/bin" ~/.bashrc; then
  echo 'export PATH=$HOME/go/bin:$PATH' >> ~/.bashrc
fi
export PATH=$HOME/go/bin:$PATH
ignite version

echo "=== Cloning Aaron Network chain repo ==="
git clone https://github.com/aaronetwork/aaronetwork-chain.git
cd aaronetwork-chain
ignite chain build
cd ..

echo "=== Initializing node ==="
aaronetworkd init moniker --chain-id aaronetwork
curl -L https://raw.githubusercontent.com/aaronetwork/chain-genesis/refs/heads/main/genesis.json -o ~/.aaronetwork/config/genesis.json

echo "=== Updating config files ==="
curl -L https://raw.githubusercontent.com/aaronetwork/validator-guide/refs/heads/main/config/config.toml -o ~/.aaronetwork/config/config.toml
curl -L https://raw.githubusercontent.com/aaronetwork/validator-guide/refs/heads/main/config/app.toml -o ~/.aaronetwork/config/app.toml

echo "=== Creating systemd service ==="
cat <<EOF | sudo tee /etc/systemd/system/aaronetworkd.service
[Unit]
Description=Aaron Network
After=network-online.target

[Service]
User=root
ExecStart=/root/go/bin/aaronetworkd start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable aaronetworkd
sudo systemctl start aaronetworkd
sudo systemctl status aaronetworkd

echo "✅ Setup complete. Node is starting..."
