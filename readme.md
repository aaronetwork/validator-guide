## ⚙️ 1. Minimum Requirement

| Parameter | Minimum Requirement |
|----------|---------------------|
| CPU      | 1 core              |
| RAM      | 2 GB                |
| Storage  | 40 GB               |
| Traffic  | 32 TB               |

## 🚀 2. Automatic Installation (Recommended)

You can install and configure your node automatically using our installation script.

Just run the following command:

`curl -s https://raw.githubusercontent.com/aaronetwork/validator-guide/refs/heads/main/setup_node.sh | bash`

This script will:
- Set up swap memory
- Install Go and Ignite CLI
- Clone the blockchain repository and build the chain
- Initialize and configure the node
- Set up and start the systemd service

## 🛠️ 3. Manual Installation

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

### Clone repo

```shell
git clone git@github.com:aaronetwork/aaronetwork-chain.git
cd aaronetwork-chain
ignite chain build
```

### Create node

`aaronetworkd init moniker --chain-id aaronetwork`

```shell
curl -L https://raw.githubusercontent.com/aaronetwork/chain-genesis/refs/heads/main/genesis.json -o ~/.aaronetwork/config/genesis.json
curl -L https://raw.githubusercontent.com/aaronetwork/validator-guide/refs/heads/main/config/config.toml -o ~/.aaronetwork/config/config.toml
curl -L https://raw.githubusercontent.com/aaronetwork/validator-guide/refs/heads/main/config/app.toml -o ~/.aaronetwork/config/app.toml
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