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
PEERS='9ffdc3cd450758f09e1c31f2548c812a5c86f141@uptick-testnet.nodejumper.io:29656,8113a2332a8ec6dab1084caa1b87123fcf22136c@95.217.4.62:26656,7831b5c5cc90fa95ea99a0cea5d1ad07dfcc7b9c@185.245.183.187:26656,e235147df1089a6d2bec6132af6512cfc859791e@65.21.225.58:27656,86f50af23369997882ca3988eabeba998b4f07cc@65.109.92.79:10656,1c66685cbf5c8dc0a739eb57c896d35eb2eed17c@141.94.139.233:28656,7a1f08486cd519270b3aeab7c6c4abf2cc07d22b@46.17.250.145:60856,d2787914515fa3aa87847c87d8701c764a73e965@199.175.98.112:26656,a818920590d15226a206ec4c73b1c5c20c56a435@65.21.134.202:26666,33de15e925c8bd20f01413b9fcf44562b488eb85@65.108.234.11:15656,b14b4e3a46180eccf00d816aed5338db925e2237@185.225.191.149:26656,aff8d7b78840eaafa6c2bafd9a76b76e565b2933@65.108.131.190:25256,3689cef89c3d87c32a1561b931af5ddd59328f5e@65.109.58.237:36656,8f6fbc1a1119f5827e1768aca3577724460fb61f@157.90.213.40:26656,e8704845eaa0f3d39fcdc9c4065f3beb344384db@142.132.152.46:27656,21ff36b28e4ecf2eee49a711a2ddc8d83e863841@209.126.4.134:31656,b483acbcae7ccd1244f588144245e9d1124c3de5@88.99.56.200:26666,bba3e95bcabaef3511eab2480c61b5fae91c34bb@65.21.176.117:26656,d42cf28de5fcf5786d78fce2936633c9eb927b2e@65.109.84.214:56656,7849e4320385434b0828a3e0206a3b69767393f6@65.109.91.227:26656,453aff3405698476967251ee253a03bedf4f0dce@178.211.139.124:15656,e4338738a85c4adb93ddd35505b9fb0c509b7ce9@65.109.132.8:26656,507999588745d6021c012b736c795a93348ae0cd@95.214.55.155:20656,0fcdc6af694d5b9995340549e5ce444dc96de3e0@195.201.197.4:15656,b9e0210809b9dfc9cd299c6e83116d7fa45c6e27@65.109.68.93:46656,0afb5ce897e69eec34fb32bf87f4a2f93f79e0b3@65.109.65.210:30656,5031d02dd9804714e3055a3eb7d91d18d533783f@194.163.172.19:26656,6af07daddb8a57c01d05d8c0894f8293a41090d0@185.245.183.122:26656,7175172406a124862dc545b8fb1e3545c35173f9@176.9.146.72:14656,d5519e378247dfb61dfe90652d1fe3e2b3005a5b@65.109.68.190:15656,d29ea798e5822c36e21dd34973f038b0203bb6e2@94.130.200.205:56656'
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
