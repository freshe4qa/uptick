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
cd $HOME
rm -rf uptick
git clone https://github.com/UptickNetwork/uptick.git
cd uptick
git checkout v0.2.6
make build -B
mv build/uptickd /usr/local/bin/uptickd

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
PEERS='9ffdc3cd450758f09e1c31f2548c812a5c86f141@uptick-testnet.nodejumper.io:29656,5badbf826e75a2afc216023dd2e7b8ad0eeb9fa6@136.243.88.91:7060,aff8d7b78840eaafa6c2bafd9a76b76e565b2933@65.108.131.190:25256,70c19420bb2d40c5a6c3466c69ead6e0877b9cc7@45.85.250.108:26656,6af07daddb8a57c01d05d8c0894f8293a41090d0@185.245.183.122:26656,d29ea798e5822c36e21dd34973f038b0203bb6e2@94.130.200.205:56656,a9bb3d5c36cf62a280c13f3e37c93a4b17707eab@142.132.196.251:46656,b483acbcae7ccd1244f588144245e9d1124c3de5@88.99.56.200:26666,61fc7df6cfcbe1403405a8ffe5b48f9b6ee75f28@213.136.86.80:46656,1c66685cbf5c8dc0a739eb57c896d35eb2eed17c@141.94.139.233:28656,f296bfda3c0c3f46059c89d3ee02f3f11d95d00b@162.55.234.70:55056,2298edffe9306e4d9370233c1d29dab567829095@144.91.78.28:26656,e235147df1089a6d2bec6132af6512cfc859791e@65.21.225.58:27656,99a47965735ea33dc6677efb3b62bb6476661b92@185.144.99.86:26656,6d52facb4924cff15ad42ee6453b1375e4176d15@65.109.104.118:10856,7840c994f5d84bf114ebb10ba704ded1c1bd12fd@65.109.112.20:11054,a3b3712dfd366c5c39f6a6b3265c88c4166da86a@161.97.93.245:26661,3689cef89c3d87c32a1561b931af5ddd59328f5e@65.109.58.237:36656,df17cf4d50ef6abf42ad6fd6548dbbffe7eecd2a@95.217.35.186:36656,7a4f1c0baa2ff31c02163fb658c4eb8d119193c7@95.214.52.173:18656,057f270561b290718a84d7b2c104f0c0ff189e38@95.217.4.62:26656,0afb5ce897e69eec34fb32bf87f4a2f93f79e0b3@65.109.65.210:30656,86f50af23369997882ca3988eabeba998b4f07cc@65.109.92.79:10656,883d6557bef1bae68c4fb569078caf0cf4c45bdd@142.132.202.50:26651,1266d32b49d7472934028ed09454ebae1c7ce09e@65.108.71.80:26656,902a93963c96589432ee3206944cdba392ae5c2d@65.108.42.105:27656,9e51f3ab29137b4b1c8e0855e5bc1dc8d4f8d2b5@65.21.238.219:26656,3cffe20d473b0bd4451d330da8b741b5d42dcb44@65.21.131.215:26666,cd79be6b60e9d2f06c85eeecb1374446b1d0ad1b@88.208.34.134:18656,45f58ce671967a10933ea3e2279be03f0ebcb42c@85.114.134.219:16656'
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.uptickd/config/config.toml

# disable indexing
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.uptickd/config/config.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.uptickd/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.uptickd/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.uptickd/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.uptickd/config/app.toml
sed -i "s/snapshot-interval *=.*/snapshot-interval = 0/g" $HOME/.uptickd/config/app.toml

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

uptickd tendermint unsafe-reset-all --home $HOME/.uptickd --keep-addr-book 
curl https://snapshots1-testnet.nodejumper.io/uptick-testnet/uptick_7000-2_2023-02-20.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.uptickd

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
