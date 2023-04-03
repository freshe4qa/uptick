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
sudo mv build/uptickd /usr/local/bin/uptickd

# config
uptickd config chain-id $UPTICK_CHAIN_ID
uptickd config keyring-backend test

# init
uptickd init $NODENAME --chain-id $UPTICK_CHAIN_ID

# download genesis and addrbook
curl -s https://raw.githubusercontent.com/UptickNetwork/uptick-testnet/main/uptick_7000-2/genesis.json > $HOME/.uptickd/config/genesis.json
curl -s https://snapshots1-testnet.nodejumper.io/uptick-testnet/addrbook.json > $HOME/.uptickd/config/addrbook.json

# set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.001auptick\"/" $HOME/.uptickd/config/app.toml

# set peers and seeds
SEEDS='f97a75fb69d3a5fe893dca7c8d238ccc0bd66a8f@uptick-seed.p2p.brocha.in:30554'
PEERS='9ffdc3cd450758f09e1c31f2548c812a5c86f141@uptick-testnet.nodejumper.io:29656,5badbf826e75a2afc216023dd2e7b8ad0eeb9fa6@136.243.88.91:7060,aff8d7b78840eaafa6c2bafd9a76b76e565b2933@65.108.131.190:25256,7a4f1c0baa2ff31c02163fb658c4eb8d119193c7@95.214.52.173:18656,e9b37cb6a5743ca1793af119f53b91cf5892fb45@65.109.88.251:34656,a9bb3d5c36cf62a280c13f3e37c93a4b17707eab@142.132.196.251:46656,f58fd7ff25183e7e0dc3c35e667641129a8bc2cd@144.76.27.79:26656,b483acbcae7ccd1244f588144245e9d1124c3de5@88.99.56.200:26666,a3b3712dfd366c5c39f6a6b3265c88c4166da86a@161.97.93.245:26661,b9d3fe835ded0b93c39befad43fb3c4964ae740f@91.195.101.100:26656,8f6fbc1a1119f5827e1768aca3577724460fb61f@157.90.213.40:26656,e24bde7fe207160442fe6b93ee376a739def5757@51.222.248.153:26656,99a47965735ea33dc6677efb3b62bb6476661b92@185.144.99.86:26656,e9fee55fdf6668e4e04927cdd85bbbbc9e9e43b1@209.145.62.101:26656,b9e0210809b9dfc9cd299c6e83116d7fa45c6e27@65.109.68.93:46656,1bb6d67af0dd1d452e294e9df430d07bccefe502@185.215.167.241:26656,3689cef89c3d87c32a1561b931af5ddd59328f5e@65.109.58.237:36656,eb5a3112a64944e2bd701ff8aa99ab95209c6310@185.198.27.110:26656,bd486ff0635581c0680e28e93453ba8a26fc5fa8@181.214.147.81:10656,7849e4320385434b0828a3e0206a3b69767393f6@65.109.91.227:26656,0afb5ce897e69eec34fb32bf87f4a2f93f79e0b3@65.109.65.210:30656,72aa8a613e563e85e8a975fa121440487a9b6e05@65.109.32.174:29656,7831b5c5cc90fa95ea99a0cea5d1ad07dfcc7b9c@185.245.183.187:26656,1266d32b49d7472934028ed09454ebae1c7ce09e@65.108.71.80:26656,af5262526a0800a29a0a7194e1488a9fa62d0005@195.3.223.208:26656,9e51f3ab29137b4b1c8e0855e5bc1dc8d4f8d2b5@65.21.238.219:26656,3cffe20d473b0bd4451d330da8b741b5d42dcb44@65.21.131.215:26666,58cf2af0e94d7c55473a1e98225a6ff25baa0402@65.21.4.10:15656,174a57a0d4b914b5a9823a5f3f47ae4b06d9809e@65.108.206.118:60956'
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
curl https://snapshots1-testnet.nodejumper.io/uptick-testnet/uptick_7000-2_2023-04-03.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.uptickd

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
