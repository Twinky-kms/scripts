#/bin/sh
cd /root/

#update, install stuff, get wallet
apt-get update >/dev/null 2>&1
apt install -y zip >/dev/null 2>&1
wget https://github.com/genix-project/genix/releases/download/v2.2.2.1/linux-binaries.zip >/dev/null 2>&1
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
echo "externalip=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')" >>genix.conf_TEMP
echo "#----" >>genix.conf_TEMP

cp genix.conf_TEMP .genixcore/genix.conf

# genixd
genixd

sleep 60

wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
cp jq-linux64 jq
chmod +x jq
mv jq /usr/bin/

bls=$(genix-cli bls generate)

blsSecret=`echo $bls | jq '.secret'| tr -d '"'`
blsPublic=`echo $bls | jq '.public' | tr -d '"'`

# genix-cli stop
genix-cli stop

echo "sleeping for 60 seconds.."
sleep 60

echo $blsSecret
echo $blsPublic

echo "masternodeblsprivkey="$blsSecret >> .genixcore/genix.conf

# genixd
genixd

echo $blsPublic > /etc/motd

sleep 30

# genix-cli masternode status
genix-cli masternode status

crontab -l > genix

echo "@reboot sleep 60 && genixd" >> genix

crontab genix
rm genix
