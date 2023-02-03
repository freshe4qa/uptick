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
PEERS='9ffdc3cd450758f09e1c31f2548c812a5c86f141@uptick-testnet.nodejumper.io:29656,0afb5ce897e69eec34fb32bf87f4a2f93f79e0b3@65.109.65.210:30656,56695e3cbe13a41c03c67670810552d5564a4b30@75.119.130.26:26656,7831b5c5cc90fa95ea99a0cea5d1ad07dfcc7b9c@185.245.183.187:26656,58cf2af0e94d7c55473a1e98225a6ff25baa0402@65.21.4.10:15656,5badbf826e75a2afc216023dd2e7b8ad0eeb9fa6@136.243.88.91:7060,50ad8485e958e71ea06ef786e422617c8c85c3cf@75.119.151.95:26656,8113a2332a8ec6dab1084caa1b87123fcf22136c@95.217.4.62:26656,38b4fa6c0e90616f18fe08a523e239499f72a06e@135.181.115.115:31656,0105e6bcc1d69031d27817110050319446101362@65.108.197.178:31656,bf71e4d50a5bec6835d69eefdafbfaf2b655f1d8@75.119.130.25:26656,d2787914515fa3aa87847c87d8701c764a73e965@199.175.98.112:26656,726826d6b019bcf097a53a43a6f9db2a4b01e511@185.252.233.153:26656,bc4dec367dc6abcef28bf739b5106c7256636334@147.182.156.35:26656,21ff36b28e4ecf2eee49a711a2ddc8d83e863841@209.126.4.134:31656,0c8bf850d4655ba2e894c6465152e7a570a3bfea@65.108.124.57:27656,d42cf28de5fcf5786d78fce2936633c9eb927b2e@65.109.84.214:56656,d5519e378247dfb61dfe90652d1fe3e2b3005a5b@65.109.68.190:15656,75aa14851ff12bd4825fe5679958dc278086e2b9@95.216.14.72:34656,3689cef89c3d87c32a1561b931af5ddd59328f5e@65.109.58.237:36656,cd79be6b60e9d2f06c85eeecb1374446b1d0ad1b@88.208.34.134:18656,883d6557bef1bae68c4fb569078caf0cf4c45bdd@142.132.202.50:26651,8f6fbc1a1119f5827e1768aca3577724460fb61f@157.90.213.40:26656,a3b3712dfd366c5c39f6a6b3265c88c4166da86a@161.97.93.245:26661,99a47965735ea33dc6677efb3b62bb6476661b92@185.144.99.86:26656,ad45ae4e49c24b3890951b963ffdaa5e6277d4b5@178.63.102.172:26656,1bb6d67af0dd1d452e294e9df430d07bccefe502@185.215.167.241:26656,f296bfda3c0c3f46059c89d3ee02f3f11d95d00b@162.55.234.70:55056,7a4f1c0baa2ff31c02163fb658c4eb8d119193c7@95.214.52.173:26656,402b733d4d328973670b2a80f83be9c98d2e5568@75.119.130.24:26656,86f50af23369997882ca3988eabeba998b4f07cc@65.109.92.79:10656'
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
