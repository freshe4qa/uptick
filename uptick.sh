#!/bin/bash

while true
do

# Logo

echo -e '\e[40m\e[91m'
echo -e '  ____                  _                    '
echo -e ' / ___|_ __ _   _ _ __ | |_ ___  _ __        '
echo -e '| |   |  __| | | |  _ \| __/ _ \|  _ \       '
echo -e '| |___| |  | |_| | |_) | || (_) | | | |      '
echo -e ' \____|_|   \__  |  __/ \__\___/|_| |_|      '
echo -e '            |___/|_|                         '
echo -e '    _                 _                      '
echo -e '   / \   ___ __ _  __| | ___ _ __ ___  _   _ '
echo -e '  / _ \ / __/ _  |/ _  |/ _ \  _   _ \| | | |'
echo -e ' / ___ \ (_| (_| | (_| |  __/ | | | | | |_| |'
echo -e '/_/   \_\___\__ _|\__ _|\___|_| |_| |_|\__  |'
echo -e '                                       |___/ '
echo -e '\e[0m'

sleep 2

# Menu

PS3='Select an action: '
options=(
"Install"
"Create Wallet"
"Create Validator"
"Exit")
select opt in "${options[@]}"
do
case $opt in

"Install")
echo "============================================================"
echo "Install start"
echo "============================================================"

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export UPTICK_CHAIN_ID=uptick_7000-2" >> $HOME/.bash_profile
source $HOME/.bash_profile

# update
sudo apt update && sudo apt upgrade -y

# packages

sudo apt install curl build-essential git wget jq make gcc tmux -y

# install go
if ! [ -x "$(command -v go)" ]; then
  ver="1.18.2"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
fi

# download binary
curl -L -k https://github.com/UptickNetwork/uptick/releases/download/v0.2.4/uptick-linux-amd64-v0.2.4.tar.gz > uptick.tar.gz
tar -xvzf uptick.tar.gz
sudo mv -f uptick-linux-amd64-v0.2.4/uptickd /usr/local/bin/uptickd
rm -rf uptick.tar.gz
rm -rf uptick-v0.2.4

# config
uptickd config chain-id $UPTICK_CHAIN_ID
uptickd config keyring-backend test

# init
uptickd init $NODENAME --chain-id $UPTICK_CHAIN_ID

# download genesis and addrbook
curl -o $HOME/.uptickd/config/genesis.json https://raw.githubusercontent.com/UptickNetwork/uptick-testnet/main/uptick_7000-2/genesis.json
curl -s https://snapshots1-testnet.nodejumper.io/uptick-testnet/addrbook.json > $HOME/.uptickd/config/addrbook.json

# set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0auptick\"/" $HOME/.uptickd/config/app.toml

# set peers and seeds
SEEDS='f97a75fb69d3a5fe893dca7c8d238ccc0bd66a8f@uptick-seed.p2p.brocha.in:30554'
PEERS='9ffdc3cd450758f09e1c31f2548c812a5c86f141@uptick-testnet.nodejumper.io:29656,d5795efc59bf4d806c829e23a26d2454f4a357a8@65.21.138.124:15656,a3b3712dfd366c5c39f6a6b3265c88c4166da86a@161.97.93.245:26661,e9b37cb6a5743ca1793af119f53b91cf5892fb45@65.109.88.251:34656,d5bad0f321d477eb4bb01474db90ebb1dbc03bc4@35.240.90.251:26656,ad563c8036250cb34f3e822280ead9c59c9537d3@185.239.209.124:31656,a6168ac0c8ed11eeeffd75154d64c2fb3de433b1@65.109.88.180:30656,18f89c33d7a070ad1dcde227f4a3dcfb435c6c7f@89.117.49.65:26656,7849e4320385434b0828a3e0206a3b69767393f6@65.109.91.227:26656,f98d3a7fef176406e84c5c9a8dd0698fc3dee5b1@83.171.249.165:31656,1e34e47eeaaa8f78f3d866ef4ce43a1d224dcdef@185.193.66.67:31656,ad45ae4e49c24b3890951b963ffdaa5e6277d4b5@178.63.102.172:26656,40ffd59440b11d63bfb8e20cfed5b36f282a06b3@154.12.238.247:31656,bd8e1b8c7617d97e40998e50a9eb49f57008b6f1@144.126.223.1:26656,c7494393eefd3e7e87a49884f5a8bdbe74e552d5@176.124.28.248:26656,b1d03edfc52afefb44b706f7a2c33c6a978a48f2@65.109.92.166:15656,1bb6d67af0dd1d452e294e9df430d07bccefe502@185.215.167.241:26656,f58fd7ff25183e7e0dc3c35e667641129a8bc2cd@144.76.27.79:26656,1f96655ed716ecace89f06f10bc10fad14b9fe61@51.89.232.234:27916,d15d0b19bcdf7ffa592b04de5362f5def6b20aa0@65.21.204.46:26667,d3441672ea7cc417449ea8e49b4b29fb06a3c869@85.239.244.129:26656,5badbf826e75a2afc216023dd2e7b8ad0eeb9fa6@136.243.88.91:7060,b724c8cb32bac64cbeb6bbde5906ecd5bb111feb@149.102.142.198:31656,bc4dec367dc6abcef28bf739b5106c7256636334@147.182.156.35:26656,507999588745d6021c012b736c795a93348ae0cd@95.214.55.155:20656,641dd4daf0a6dbdb589ba8373a86b183a7b84292@65.109.108.152:23986,b04eef84a7227abb5d4c59c0fa7eec35367b90b7@34.125.34.48:15656,aff8d7b78840eaafa6c2bafd9a76b76e565b2933@65.108.131.190:25256,e4826216c443fea2ffd4b4ce2b4b071ab2c33a8b@34.68.116.18:15656,967e0f06ad8b16dee6a8a6b8a48e8e5a63fdd810@178.211.139.225:7656,7dace139a0389ca95c5eda64ddf19a01e6d60d02@95.214.52.206:26656,e107288acd6775b42ea4c663c594b841f3bc9b47@84.46.254.35:15656,1c66685cbf5c8dc0a739eb57c896d35eb2eed17c@141.94.139.233:28656,b483acbcae7ccd1244f588144245e9d1124c3de5@88.99.56.200:26666,a41939c0e465e77bb57a84a51ce5623d349718b1@5.78.45.233:26656,e0677d36e1b6d7925369a9c4d861c6606f74497b@5.75.187.159:26656,fb344eb9e5ed4b0dc663a6bc03281a4731489a0a@185.197.194.39:26656,75aa14851ff12bd4825fe5679958dc278086e2b9@95.216.14.72:34656,2664f38bb46b52e55f0a951f0a00c050f8e42790@5.9.147.185:56458,e5da7ceb59b783f7368743a8913171e263baac57@199.175.98.113:26656,f565936b574ce5f23a04e9470dfa05ddd06b867d@95.70.238.194:15656,9dd656b612b8e6bf15410185414f517ae521c0d6@64.227.112.132:15656,7a1f08486cd519270b3aeab7c6c4abf2cc07d22b@46.17.250.145:60856,b9d3fe835ded0b93c39befad43fb3c4964ae740f@91.195.101.100:26656,7613c8f2851fdb4ff9d4b7f23ff5161b66126f9c@85.239.243.209:26656,d2787914515fa3aa87847c87d8701c764a73e965@199.175.98.112:26656,360c6a06c78502c918818c90d035572a1c75ec9a@178.62.64.246:26656,902a93963c96589432ee3206944cdba392ae5c2d@65.108.42.105:27656,e235147df1089a6d2bec6132af6512cfc859791e@65.21.225.58:27656,58cf2af0e94d7c55473a1e98225a6ff25baa0402@65.21.4.10:15656,38d149fd90fdc0cd3509b697ad65ff9f6f20cd8f@65.108.6.45:60956'
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.uptickd/config/config.toml

# disable indexing
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.uptickd/config/config.toml

# config pruning
pruning="nothing"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.uptickd/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.uptickd/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.uptickd/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.uptickd/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.uptickd/config/config.toml

# create service
sudo tee /etc/systemd/system/uptickd.service > /dev/null << EOF
[Unit]
Description=Uptick Network Node
After=network-online.target
[Service]
User=$USER
ExecStart=$(which uptickd) start
Restart=on-failure
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

uptickd tendermint unsafe-reset-all --home $HOME/.uptickd/ --keep-addr-book

SNAP_NAME=$(curl -s https://snapshots1-testnet.nodejumper.io/uptick-testnet/ | egrep -o ">uptick_7000-2.*\.tar.lz4" | tr -d ">")
curl https://snapshots1-testnet.nodejumper.io/uptick-testnet/${SNAP_NAME} | lz4 -dc - | tar -xf - -C $HOME/.uptickd

# start service
sudo systemctl daemon-reload
sudo systemctl enable uptickd
sudo systemctl start uptickd

break
;;

"Create Wallet")
uptickd keys add $WALLET
echo "============================================================"
echo "Save address and mnemonic"
echo "============================================================"
UPTICK_WALLET_ADDRESS=$(uptickd keys show $WALLET -a)
UPTICK_VALOPER_ADDRESS=$(uptickd keys show $WALLET --bech val -a)
echo 'export UPTICK_WALLET_ADDRESS='${UPTICK_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export UPTICK_VALOPER_ADDRESS='${UPTICK_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile

break
;;

"Create Validator")
uptickd tx staking create-validator \
  --amount 5000000000000000000auptick \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(uptickd tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $UPTICK_CHAIN_ID \
  --gas=auto
  
break
;;

"Exit")
exit
;;
*) echo "invalid option $REPLY";;
esac
done
done
