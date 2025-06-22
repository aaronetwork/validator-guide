### Minimum Requirement

| Parameter | Minimum Requirement |
|----------|---------------------|
| CPU      | 1 core              |
| RAM      | 2 GB                |
| Storage  | 40 GB               |
| Traffic  | 32 TB               |

### Create swap

```shell
fallocate -l 8G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
swapon --show
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
free -h
```

### Install Golang

```shell
wget https://go.dev/dl/go1.24.2.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.24.2.linux-amd64.tar.gz
```

`nano ~/.bashrc`

Add to end line:
`export PATH=$PATH:/usr/local/go/bin`

```shell
source ~/.bashrc
go version
```

### Install Ignite Cli

```shell
git clone https://github.com/ignite/cli.git
cd cli
git checkout v28.5.3
go install ./ignite/cmd/ignite
```

`nano ~/.bashrc`

Add to end line:
`export PATH=$HOME/go/bin:$PATH`

```shell
source ~/.bashrc
ignite version
```

### SSH key

`ssh-keygen -t rsa -b 4096 -C "your_email@example.com"`

### Clone repo

```shell
git clone git@github.com:aaronetwork/aaronetwork-chain.git
cd aaronetwork-chain
ignite chain build
```

### Create node

`aaronetworkd init moniker --chain-id aaronetwork`

`curl -L https://raw.githubusercontent.com/aaronetwork/chain-genesis/refs/heads/main/genesis.json -o ~/.aaronetwork/config/genesis.json`

```shell
sed -i 's/^minimum-gas-prices *=.*/minimum-gas-prices = "0.001uaaron"/' ~/.aaronetwork/config/app.toml
sed -i 's|^seeds *=.*|seeds = "dc647a7389d3396b0a0d72d71240b02c30c47ef7@63.250.41.78:26656,162607f091deda607273bf2f66c77e50e1cabf3f@89.110.110.161:26656"|' ~/.aaronetwork/config/config.toml
sed -i 's|^persistent_peers *=.*|persistent_peers = "dc647a7389d3396b0a0d72d71240b02c30c47ef7@63.250.41.78:26656,162607f091deda607273bf2f66c77e50e1cabf3f@89.110.110.161:26656"|' ~/.aaronetwork/config/config.toml
sed -i 's|^cors_allowed_origins = .*|cors_allowed_origins = ["*"]|' ~/.aaronetwork/config/config.toml
sed -i 's|laddr = "tcp://127.0.0.1:26657"|laddr = "tcp://0.0.0.0:26657"|' ~/.aaronetwork/config/config.toml
sed -i 's|^enable = .*|enable = true|' ~/.aaronetwork/config/config.toml
sed -i 's|^trust_height = .*|trust_height = 3013516|' ~/.aaronetwork/config/config.toml
sed -i 's|^trust_hash = .*|trust_hash = "C3EEA953DBF43205C5B4DB4103E1409632FCE4CC0C4C1BEEC139A98C2C4BC603"|' ~/.aaronetwork/config/config.toml
sed -i 's/^pruning = .*/pruning = "custom"/' ~/.aaronetwork/config/app.toml
sed -i 's/^pruning-keep-recent = .*/pruning-keep-recent = "86400"/' ~/.aaronetwork/config/app.toml
sed -i 's/^pruning-keep-every = .*/pruning-keep-every = "0"/' ~/.aaronetwork/config/app.toml
sed -i 's/^pruning-interval = .*/pruning-interval = "100"/' ~/.aaronetwork/config/app.toml
```

### Systemctl

`nano /etc/systemd/system/aaronetworkd.service`

And insert:

```shell
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
```

```
sudo systemctl daemon-reload
sudo systemctl start aaronetworkd
sudo systemctl enable aaronetworkd
sudo systemctl status aaronetworkd
```