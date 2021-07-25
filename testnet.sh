#/bin/sh
cd /root/

#update, install stuff, get wallet
apt-get update > /dev/null 2>&1
apt install -y zip > /dev/null 2>&1
wget https://github.com/Twinky-kms/genix/releases/download/v2.2.3-dev1/linux-binaries.zip > /dev/null 2>&1
unzip linux-binaries.zip > /dev/null 2>&1

sudo fallocate -l G /swapfile; ls -lh /swapfile; sudo chmod 600 /swapfile; ls -lh /swapfile; sudo mkswap /swapfile; sudo swapon /swapfile; sudo swapon --show; sudo cp /etc/fstab /etc/fstab.bak; echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

cd linux-binaries/
mv genixd /usr/bin/
mv genix-cli /usr/bin/
mv genix-tx /usr/bin/

cd /root/
mkdir .genixcore/
##### for multi mn per machine #####
# mkdir .genixcore-2/
# mkdir .genixcore-3/

ufw allow 22/tcp
#mainnet
# ufw allow 43649/tcp

#testnet
ufw allow 32538/tcp
ufw allow 32539/tcp
ufw allow 32540/tcp

##### for multi mn per machine #####

# echo "#!/bin/bash" >~/master-cli.sh
# echo "./genix-cli-'$1'.sh $*"

# echo '#!/bin/bash' >~/genixd-1.sh
# echo "genixd -testnet -datadir=/root/.genixcore/ -conf=genix.conf -port=32538" '$*' >>~/genixd-1.sh
# echo '#!/bin/bash' >~/genix-cli-1.sh
# echo "genix-cli -testnet -datadir=/root/.genixcore/ -conf=genix.conf "'$*' >>~/genix-cli-1.sh
# echo '#!/bin/bash' >~/genix-tx-1.sh
# echo "genix-tx -datadir=/root/.genixcore/ -conf=genix.conf "'$*' >>~/genix-tx-1.sh

# echo '#!/bin/bash' >~/genixd-2.sh
# echo "genixd -testnet -datadir=/root/.genixcore-2/ -conf=genix.conf -port=32539 -rpcport=3333 "'$*' >>~/genixd-2.sh
# echo '#!/bin/bash' >~/genix-cli-2.sh
# echo "genix-cli -testnet -datadir=/root/.genixcore-2/ -conf=genix.conf -rpcport=3333 "'$*' >>~/genix-cli-2.sh
# echo '#!/bin/bash' >~/genix-tx-2.sh
# echo "genix-tx -datadir=/root/.genixcore-2/ -conf=genix.conf "'$*' >>~/genix-tx-2.sh

# echo '#!/bin/bash' >~/genixd-3.sh
# echo "genixd -testnet -datadir=/root/.genixcore-3/ -conf=genix.conf -port=32540 -rpcport=4444 "'$*' >>~/genixd-3.sh
# echo '#!/bin/bash' >~/genix-cli-3.sh
# echo "genix-cli -testnet -datadir=/root/.genixcore-3/ -conf=genix.conf -rpcport=4444 "'$*' >>~/genix-cli-3.sh
# echo '#!/bin/bash' >~/genix-tx-3.sh
# echo "genix-tx -datadir=/root/.genixcore-3/ -conf=genix.conf "'$*' >>~/genix-tx-3.sh

# chmod 755 /root/genix*.sh

sleep 10

cd /root/

#todo generate random rpcusr/pass vars. 
echo "#----" >> genix.conf_TEMP
echo "rpcuser=XXXXXXXXXXXXX" >> genix.conf_TEMP
echo "rpcpassword=XXXXXXXXXXXXXXXXXXXXXXXXXXXX" >> genix.conf_TEMP
echo "rpcallowip=127.0.0.1" >> genix.conf_TEMP
echo "#----" >> genix.conf_TEMP
echo "listen=1" >> genix.conf_TEMP
echo "server=1" >> genix.conf_TEMP
echo "daemon=1" >> genix.conf_TEMP
echo "#----" >> genix.conf_TEMP
#echo "masternodeblsprivkey=" >> genix.conf_TEMP
echo "externalip=$(hostname -I)" >> genix.conf_TEMP
echo "#----" >> genix.conf_TEMP

cp genix.conf_TEMP .genixcore/genix.conf
##### for multi mn per machine #####
# cp genix.conf_TEMP .genixcore-2/genix.conf
# cp genix.conf_TEMP .genixcore-3/genix.conf

echo "masternodeblsprivkey=PUTYOURKEYHERE" >> .genixcore/genix.conf
##### for multi mn per machine #####
# echo "masternodeblsprivkey=KEY" >> .genixcore-2/genix.conf
# echo "masternodeblsprivkey=KEY" >> .genixcore-3/genix.conf

genixd 

# cd /root/
# ./genixd-1.sh
# ./genixd-2.sh
# ./genixd-3.sh

#ufw enable
