#/bin/sh
cd /root/

#stop genixd
genix-cli stop 
genix-cli -testnet stop

rm linux-binaries.zip
rm genix-qt

wget https://github.com/Twinky-kms/genix/releases/download/v2.2.3-dev1/linux-binaries.zip 
unzip linux-binaries.zip 
chmod +x genixd genix-cli genix-tx
mv genixd /usr/bin
mv genix-cli /usr/bin
mv genix-tx /usr/bin
rm genix-qt

sleep 120

genixd -reindex 
genixd -testnet


sleep 90

genix-cli getinfo
genix-cli clearbanned
genix-cli -testnet getinfo




