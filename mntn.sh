#/bin/sh
cd /root/

#update, install stuff, get wallet
apt-get update >/dev/null 2>&1
apt install -y zip >/dev/null 2>&1
wget https://github.com/Twinky-kms/genix/releases/download/v2.2.3-dev1/linux-binaries.zip >/dev/null 2>&1
unzip linux-binaries.zip >/dev/null 2>&1

sudo fallocate -l 2G /swapfile
ls -lh /swapfile
sudo chmod 600 /swapfile
ls -lh /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo swapon --show
sudo cp /etc/fstab /etc/fstab.bak
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

cd linux-binaries/
chmod +x genixd genix-cli genix-tx
mv genixd /usr/bin/
mv genix-cli /usr/bin/
mv genix-tx /usr/bin/

cd /root/
mkdir .genixcore/

ufw allow 22/tcp
ufw allow 43649/tcp
#testnet
ufw allow 32538/tcp
echo "y" | sudo ufw enable

cd /root/

#todo generate random rpcusr/pass vars.
echo "#----" >>genix.conf_TEMP
echo "rpcuser=user"$(shuf -i 100000-10000000 -n 1) >> genix.conf_TEMP
echo "rpcpassword=pass"$(shuf -i 100000-10000000 -n 1) >> genix.conf_TEMP
echo "rpcallowip=127.0.0.1" >>genix.conf_TEMP
echo "#----" >>genix.conf_TEMP
echo "listen=1" >>genix.conf_TEMP
echo "server=1" >>genix.conf_TEMP
echo "daemon=1" >>genix.conf_TEMP
echo "#----" >>genix.conf_TEMP
#echo "masternodeblsprivkey=" >> genix.conf_TEMP
echo "externalip=$(hostname -I)" >>genix.conf_TEMP
echo "#----" >>genix.conf_TEMP

cp genix.conf_TEMP .genixcore/genix.conf

echo "masternodeblsprivkey=KEY" >>.genixcore/genix.conf

genixd
genixd -testnet

# cd /root/
# ./genixd-1.sh
# ./genixd-2.sh
# ./genixd-3.sh

#ufw enable

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
