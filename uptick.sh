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
UPTICK_PORT=15
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export UPTICK_CHAIN_ID=uptick_7000-2" >> $HOME/.bash_profile
echo "export UPTICK_PORT=${UPTICK_PORT}" >> $HOME/.bash_profile
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
uptickd config node tcp://localhost:${UPTICK_PORT}657

# init
uptickd init $NODENAME --chain-id $UPTICK_CHAIN_ID

# download genesis and addrbook
curl -o $HOME/.uptickd/config/genesis.json https://raw.githubusercontent.com/UptickNetwork/uptick-testnet/main/uptick_7000-2/genesis.json

# set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0auptick\"/" $HOME/.uptickd/config/app.toml

# set peers and seeds
SEEDS='f97a75fb69d3a5fe893dca7c8d238ccc0bd66a8f@uptick-seed.p2p.brocha.in:30554'
PEERS='9ffdc3cd450758f09e1c31f2548c812a5c86f141@uptick-testnet.nodejumper.io:29656,ad563c8036250cb34f3e822280ead9c59c9537d3@185.239.209.124:31656,8340a33a3794dfef56159f412012c16ce51d96dc@65.109.85.52:46656,5badbf826e75a2afc216023dd2e7b8ad0eeb9fa6@136.243.88.91:7060,4dfcdb373e4b8d121b89b779e5ca08b957afd884@194.163.180.77:31656,3ac3a67c7caf0263d794eff6c6759fa32a986309@65.109.49.111:46656,1c66685cbf5c8dc0a739eb57c896d35eb2eed17c@141.94.139.233:28656,18f89c33d7a070ad1dcde227f4a3dcfb435c6c7f@89.117.49.65:26656,6b5375296e81501b0db0a34a7a04f39520400214@65.108.45.200:27565,c9f643cde730e12e49d912c5110f5ebeb6545f0e@171.244.185.191:26656,1eee80b5cda2b1c3bcab199d9aca24f48cb903da@46.4.121.72:15656,3666c65e99775b8149396fd5c781dec6a29fb13b@75.119.144.48:31656,e8704845eaa0f3d39fcdc9c4065f3beb344384db@142.132.152.46:27656,1f96655ed716ecace89f06f10bc10fad14b9fe61@51.89.232.234:27916,8f6fbc1a1119f5827e1768aca3577724460fb61f@157.90.213.40:26656,9edbf5bbc666dd3b75574788106e8396c7324ac2@84.46.241.249:26656,3cffe20d473b0bd4451d330da8b741b5d42dcb44@65.21.131.215:26666,d3441672ea7cc417449ea8e49b4b29fb06a3c869@85.239.244.129:26656,15c026567d5e7535fbd5b7067babe3b1fd17aba0@207.180.215.98:26656,78fa616bb67efd86e48529fde26309681ee213b6@65.108.199.222:26636,421955c25f58111f99c04d24a0f07810b4e585ac@173.249.14.30:31656,bf626ac1b0c733c0937d70d8c834c94c3e4b9033@65.108.129.29:14656,2d892493335b4bb1582dabcaa1e832bcba041e79@95.217.4.62:26656,45f58ce671967a10933ea3e2279be03f0ebcb42c@85.114.134.219:16656,0afb5ce897e69eec34fb32bf87f4a2f93f79e0b3@65.109.65.210:30656,4c062185dbf436903124fe6c2b2eea5067d7a9c4@154.12.243.0:31656,b1d03edfc52afefb44b706f7a2c33c6a978a48f2@65.109.92.166:15656,e235147df1089a6d2bec6132af6512cfc859791e@65.21.225.58:27656,40ffd59440b11d63bfb8e20cfed5b36f282a06b3@154.12.238.247:31656,5d540990a9fd7f36584f1473bf2a5746ffffece4@65.108.13.185:27464,af5262526a0800a29a0a7194e1488a9fa62d0005@195.3.223.208:26656,a6168ac0c8ed11eeeffd75154d64c2fb3de433b1@65.109.88.180:30656,20aaf646f9c766a8b81d838554ba6e593122ed1f@46.4.122.236:36656,a3b3712dfd366c5c39f6a6b3265c88c4166da86a@161.97.93.245:26661,b483acbcae7ccd1244f588144245e9d1124c3de5@88.99.56.200:26666,7dace139a0389ca95c5eda64ddf19a01e6d60d02@95.214.52.206:26656,38fc28d774d8a0abb405c1440880928bdb4aab2d@142.132.199.236:15656,40a93c4be9e2dcb155d60e174c0e00d6808283e7@65.109.52.56:26656,e9b37cb6a5743ca1793af119f53b91cf5892fb45@65.109.88.251:34656,49c9876d8ad31ccfd3a169fa93d568ceec946476@65.108.229.46:26656,1bb6d67af0dd1d452e294e9df430d07bccefe502@185.215.167.241:26656,570a72436a64ecf88e1dc51d7804fae114e12fff@162.55.245.219:15656,3dbbfac16932869e66e44a9ef443102e6677cf82@85.239.233.156:26656,d15d0b19bcdf7ffa592b04de5362f5def6b20aa0@65.21.204.46:26667,9b7b2fb9d1416f9feadf5a58b29de0bc150d974d@37.187.144.187:26656,c044b30444bf272c6ff4958625281f21a2683f09@5.189.183.206:34656,402b733d4d328973670b2a80f83be9c98d2e5568@75.119.130.24:26656,33de15e925c8bd20f01413b9fcf44562b488eb85@65.108.234.11:15656,29f6fee3545bd63cc7abf46c05d82d952d3d112d@38.242.216.89:26656,7d0f2b6860cb1b8fd522a466970c8385da2c89a3@65.108.232.174:15656,1f47b98002f5208f62d596f924ebbb3b5df5c190@185.245.183.172:26656'
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

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://0.0.0.0:26658\"%proxy_app = \"tcp://0.0.0.0:${UPTICK_PORT}658\"%; s%^laddr = \"tcp://0.0.0.0:26657\"%laddr = \"tcp://0.0.0.0:${UPTICK_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${UPTICK_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${UPTICK_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${UPTICK_PORT}660\"%" $HOME/.uptickd/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${UPTICK_PORT}317\"%; s%^address = \":8080\"%address = \":${UPTICK_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${UPTICK_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${UPTICK_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${UPTICK_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${UPTICK_PORT}546\"%" $HOME/.uptickd/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.uptickd/config/config.toml

uptickd tendermint unsafe-reset-all --home $HOME/.uptickd

# create service
sudo tee /etc/systemd/system/uptickd.service > /dev/null <<EOF
[Unit]
Description=uptick
After=network-online.target
[Service]
User=$USER
ExecStart=$(which uptickd) start --home $HOME/.uptickd
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

cp $HOME/.uptickd/data/priv_validator_state.json $HOME/.uptickd/priv_validator_state.json.backup

SNAP_NAME=$(curl -s https://snapshots1-testnet.nodejumper.io/uptick-testnet/ | egrep -o ">uptick_7000-2.*\.tar.lz4" | tr -d ">")
curl https://snapshots1-testnet.nodejumper.io/uptick-testnet/${SNAP_NAME} | lz4 -dc - | tar -xf - -C $HOME/.uptickd

mv $HOME/.uptickd/priv_validator_state.json.backup $HOME/.uptickd/data/priv_validator_state.json

# start service
sudo systemctl daemon-reload
sudo systemctl enable uptickd
sudo systemctl restart uptickd

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
