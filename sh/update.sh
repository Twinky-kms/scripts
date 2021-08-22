#/bin/sh
cd /root/

#stop genixd
genix-cli stop 
genix-cli -testnet stop

rm linux-binaries.zip

wget https://github.com/Twinky-kms/genix/releases/download/v2.2.3-dev1/linux-binaries.zip 
unzip linux-binaries.zip 

sleep 10

chmod +x genixd genix-cli genix-tx
mv genixd /usr/bin
mv genix-cli /usr/bin
mv genix-tx /usr/bin
rm genix-qt

genixd 
genixd -testnet


sleep 20

genix-cli getinfo
genix-cli -testnet getinfo



