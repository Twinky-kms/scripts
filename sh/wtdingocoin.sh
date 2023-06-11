#!/bin/bash
WALLET_DOWNLOAD_LINK="https://github.com/dingocoincrypto/dingocoin/releases/download/v1.16.0.6/linux-binaries.zip"
CLONE_LINK="https://github.com/twinky-kms/wdingocoin-bsc"
TARGET_BRANCH="develop"

curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
apt -y update
apt -y upgrade
apt install -y unzip snap certbot curl dirmngr apt-transport-https lsb-release ca-certificates gcc g++ make nodejs sqlite3 pkg-config libssl-dev libudev-dev
npm install -g yarn
cd $HOME
mkdir binaries/
cd binaries/
wget $WALLET_DOWNLOAD_LINK
unzip linux-binaries.zip
rm dingocoin-tx
chmod +x dingo*
cp dingocoin* /usr/bin/

cat > dingocoin.conf <<EOF

rpcuser=averycoolname
rpcpassword=averycoolpassword
rpcthreads=8
rpcallowip=127.0.0.1
rpcport=34646

EOF

dingocoind -testnet -daemon
cd $HOME/.dingocoin/
sleep 5
CHANGE_ADDRESS=$(dingocoin-cli -testnet getnewaddress)
CHANGE_ADDRESS_VALIDATE=$(dingocoin-cli -testnet validateaddress $CHANGE_ADDRESS)

cd $HOME
git clone $CLONE_LINK
cd wdingocoin-bsc/
git checkout $TARGET_BRANCH
yarn install

echo "change address multisig: $CHANGE_ADDRESS_VALIDATE"
