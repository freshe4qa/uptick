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
PEERS='9ffdc3cd450758f09e1c31f2548c812a5c86f141@uptick-testnet.nodejumper.io:29656,0afb5ce897e69eec34fb32bf87f4a2f93f79e0b3@65.109.65.210:30656,fe1604c718ab19e8763ad85ed439aad5b5162718@51.250.94.153:26656,5d540990a9fd7f36584f1473bf2a5746ffffece4@65.108.13.185:27464,883d6557bef1bae68c4fb569078caf0cf4c45bdd@142.132.202.50:26651,5badbf826e75a2afc216023dd2e7b8ad0eeb9fa6@136.243.88.91:7060,50ad8485e958e71ea06ef786e422617c8c85c3cf@75.119.151.95:26656,b9e0210809b9dfc9cd299c6e83116d7fa45c6e27@65.109.68.93:46656,38b4fa6c0e90616f18fe08a523e239499f72a06e@135.181.115.115:31656,902a93963c96589432ee3206944cdba392ae5c2d@65.108.42.105:27656,a9bb3d5c36cf62a280c13f3e37c93a4b17707eab@142.132.196.251:46656,77b5fbf5a81f50613199164c56c872273ee5df8c@65.109.27.156:28656,1266d32b49d7472934028ed09454ebae1c7ce09e@65.108.71.80:26656,e8704845eaa0f3d39fcdc9c4065f3beb344384db@142.132.152.46:27656,b1f4cbece3a83ea55ba28a50281eaa3af9119cd4@65.21.129.95:21256,0c8bf850d4655ba2e894c6465152e7a570a3bfea@65.108.124.57:27656,21ff36b28e4ecf2eee49a711a2ddc8d83e863841@209.126.4.134:31656,7840c994f5d84bf114ebb10ba704ded1c1bd12fd@65.109.112.20:11054,7831b5c5cc90fa95ea99a0cea5d1ad07dfcc7b9c@185.245.183.187:26656,96a2fd192db329ff9df3f44569f0fe452ea9f19e@65.108.232.110:15656,aff8d7b78840eaafa6c2bafd9a76b76e565b2933@65.108.131.190:25256,72aa8a613e563e85e8a975fa121440487a9b6e05@65.109.32.174:29656,8f6fbc1a1119f5827e1768aca3577724460fb61f@157.90.213.40:26656,a3b3712dfd366c5c39f6a6b3265c88c4166da86a@161.97.93.245:26661,99a47965735ea33dc6677efb3b62bb6476661b92@185.144.99.86:26656,ad45ae4e49c24b3890951b963ffdaa5e6277d4b5@178.63.102.172:26656,1bb6d67af0dd1d452e294e9df430d07bccefe502@185.215.167.241:26656,f296bfda3c0c3f46059c89d3ee02f3f11d95d00b@162.55.234.70:55056,86f50af23369997882ca3988eabeba998b4f07cc@65.109.92.79:10656,726826d6b019bcf097a53a43a6f9db2a4b01e511@185.252.233.153:26656,d3107602737ec267cd963672d14068b4f30fc633@213.239.207.175:26651'
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
