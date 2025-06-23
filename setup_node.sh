#!/bin/bash

set -e

echo "=== Creating 8G swap ==="
fallocate -l 8G /swapfile
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
go install ./ignite/cmd/ignite
cd ..
rm -rf cli

# Add go bin to PATH if not already present
if ! grep -q "\$HOME/go/bin" ~/.bashrc; then
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
sed -i 's/^minimum-gas-prices *=.*/minimum-gas-prices = "0.001uaaron"/' ~/.aaronetwork/config/app.toml
sed -i 's|^seeds *=.*|seeds = "dc647a7389d3396b0a0d72d71240b02c30c47ef7@63.250.41.78:26656,9373f89c3b47a346a6b347208a35079a920511cd@146.103.96.113:26656,a815343c840c2d24e85639b541335103bb0b82a3@146.103.99.198"|' ~/.aaronetwork/config/config.toml
sed -i 's|^persistent_peers *=.*|persistent_peers = "dc647a7389d3396b0a0d72d71240b02c30c47ef7@63.250.41.78:26656,9373f89c3b47a346a6b347208a35079a920511cd@146.103.96.113:26656,a815343c840c2d24e85639b541335103bb0b82a3@146.103.99.198"|' ~/.aaronetwork/config/config.toml
sed -i 's|^cors_allowed_origins = .*|cors_allowed_origins = ["*"]|' ~/.aaronetwork/config/config.toml
sed -i 's|laddr = "tcp://127.0.0.1:26657"|laddr = "tcp://0.0.0.0:26657"|' ~/.aaronetwork/config/config.toml
sed -i 's|^enable = .*|enable = true|' ~/.aaronetwork/config/config.toml
sed -i 's|^rpc_servers = .*|rpc_servers = "63.250.41.78:26657,146.103.96.113:26657,146.103.99.198:26657"|' ~/.aaronetwork/config/config.toml
sed -i 's|^trust_height = .*|trust_height = 3013516|' ~/.aaronetwork/config/config.toml
sed -i 's|^trust_hash = .*|trust_hash = "C3EEA953DBF43205C5B4DB4103E1409632FCE4CC0C4C1BEEC139A98C2C4BC603"|' ~/.aaronetwork/config/config.toml
sed -i 's/^pruning = .*/pruning = "custom"/' ~/.aaronetwork/config/app.toml
sed -i 's/^pruning-keep-recent = .*/pruning-keep-recent = "86400"/' ~/.aaronetwork/config/app.toml
sed -i 's/^pruning-keep-every = .*/pruning-keep-every = "0"/' ~/.aaronetwork/config/app.toml
sed -i 's/^pruning-interval = .*/pruning-interval = "100"/' ~/.aaronetwork/config/app.toml
sed -i 's/^snapshot-interval = .*/snapshot-interval = 1000/' ~/.aaronetwork/config/app.toml
sed -i 's/^snapshot-keep-recent = .*/snapshot-keep-recent = 2/' ~/.aaronetwork/config/app.toml

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
