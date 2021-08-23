#/bin/sh
cd /root/

#stop genixd
#genix-cli stop 
genix-cli -testnet stop

rm linux-binaries.zip
rm genix-qt

wget https://github.com/Twinky-kms/genix/releases/download/v2.2.3-dev1/linux-binaries.zip 
unzip linux-binaries.zip 

sleep 60

chmod +x genixd genix-cli genix-tx
mv genixd /usr/bin
mv genix-cli /usr/bin
mv genix-tx /usr/bin
rm genix-qt

#genixd 
genixd -testnet


sleep 30

#genix-cli getinfo
genix-cli -testnet getinfo




