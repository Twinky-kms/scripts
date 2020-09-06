#!/bin/bash

cd ~
echo "****************************************************************************"
echo "* Ubuntu 18.04 is the recommended operating system for this install.       *"
echo "*                                                                          *"
echo "* This script will install and configure your Pigeoncoin masternodes.           *"
echo "****************************************************************************"
echo && echo && echo
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!                                                 !"
echo "! Make sure you double check before hitting enter !"
echo "!                                                 !"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo && echo && echo

echo "Do you want to install all needed dependencies (no if you did it before)? [y/n]"
read DOSETUP

if [[ $DOSETUP =~ "y" ]]; then

    cd

    if [[ -d genix-fork/ ]]; then
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "!                                                 !"
    echo "!    Detected previous build files, deleting..    !"
    echo "!                                                 !"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        rm -r genix-fork/
    fi 

    sudo apt-get -y update
    sudo apt-get -y upgrade
    sudo apt-get -y install git
    sudo apt-get install -y curl 
    sudo apt-get install -y build-essential
    sudo apt-get install -y libtool
    sudo apt-get install -y autotools-dev
    sudo apt-get install -y automake pkg-config
    sudo apt-get install -y python3
    sudo apt-get install -y bsdmainutils
    sudo apt-get install -y cmake
    cd

    cd /var
    sudo touch swap.img
    sudo chmod 600 swap.img
    sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=2000
    sudo mkswap /var/swap.img
    sudo swapon /var/swap.img
    sudo free
    sudo echo "/var/swap.img none swap sw 0 0" >>/etc/fstab
    cd

    cd 
    git clone https://github.com/farsider350/genix-fork.git
    cd genix-fork/
    git checkout v2.2.1
    bash build.sh
    rm /usr/bin/genixd*
    mv src/genixd /usr/bin
    mv src/genix-cli /usr/bin
    mv src/genix-tx /usr/bin
    #rm -r /root/genix-fork/

    sudo apt-get install -y ufw
    sudo ufw allow ssh/tcp
    sudo ufw limit ssh/tcp
    sudo ufw logging on
    echo "y" | sudo ufw enable
    sudo ufw status

    mkdir -p ~/bin
    echo 'export PATH=~/bin:$PATH' >~/.bash_aliases
    source ~/.bashrc
fi

## Setup conf
mkdir -p ~/bin

MNCOUNT=""
re='^[0-9]+$'
while ! [[ $MNCOUNT =~ $re ]]; do
    echo ""
    echo "How many nodes do you want to create on this server?, followed by [ENTER]:"
    read MNCOUNT
done

for i in $(seq 1 1 $MNCOUNT); do
    echo ""
    echo "Enter alias for new node"
    read ALIAS

    echo ""
    echo "Enter port 18765 for node $ALIAS"
    read PORT

    echo ""
    echo "Enter masternode private key for node $ALIAS"
    read PRIVKEY

    echo ""
    echo "Configure your masternodes now!"
    echo "Type the IP of this server, followed by [ENTER]:"
    read IP

    echo ""
    echo "Enter RPC Port 4001"
    read RPCPORT

    ALIAS=${ALIAS,,}
    CONF_DIR=~/.genixcore$ALIAS

    # Create scripts
    echo '#!/bin/bash' >~/bin/genixd_$ALIAS.sh
    echo "genixd -daemon -conf=$CONF_DIR/genix.conf -datadir=$CONF_DIR "'$*' >>~/bin/genixd_$ALIAS.sh
    echo '#!/bin/bash' >~/bin/genix-cli_$ALIAS.sh
    echo "genix-cli -conf=$CONF_DIR/genix.conf -datadir=$CONF_DIR "'$*' >>~/bin/genix-cli_$ALIAS.sh
    echo '#!/bin/bash' >~/bin/genix-tx_$ALIAS.sh
    echo "genix-tx -conf=$CONF_DIR/genix.conf -datadir=$CONF_DIR "'$*' >>~/bin/genix-tx_$ALIAS.sh
    chmod 755 ~/bin/genix*.sh

    mkdir -p $CONF_DIR
    echo "testnet=1" >> genix.conf_TEMP
    echo "" >> genix.conf_TEMP
    echo "[test]" >> genix.conf_TEMP
    echo "rpcuser=user"$(shuf -i 100000-10000000 -n 1) >> genix.conf_TEMP
    echo "rpcpassword=pass"$(shuf -i 100000-10000000 -n 1) >> genix.conf_TEMP
    echo "rpcallowip=127.0.0.1" >> genix.conf_TEMP
    echo "rpcport=$RPCPORT" >> genix.conf_TEMP
    echo "listen=1" >> genix.conf_TEMP
    echo "server=1" >> genix.conf_TEMP
    echo "daemon=1" >> genix.conf_TEMP
    echo "port=$PORT" >> genix.conf_TEMP
    echo "externalip=$IP" >> genix.conf_TEMP
    echo "bind=$IP" >> genix.conf_TEMP
    echo "logtimestamps=1" >> genix.conf_TEMP
    echo "maxconnections=64" >> genix.conf_TEMP
    echo "" >> genix.conf_TEMP

    echo "addnode=138.68.75.8:18765" >> genix.conf_TEMP
    echo "addnode=159.89.177.213:18765" >> genix.conf_TEMP

    echo "" >>genix.conf_TEMP
    echo "masternodeprivkey=$PRIVKEY" >> genix.conf_TEMP
    sudo ufw allow $PORT/tcp

    mv genix.conf_TEMP $CONF_DIR/genix.conf

    sh ~/bin/genixd_$ALIAS.sh
done
