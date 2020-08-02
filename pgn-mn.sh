buildCoin() {
    mkdir dash-fork
    cd dash-fork
    git clone https://github.com/akshaynexus/pigeoncoin-dash
    cd pigeoncoin-dash
    export HOST=x86_64-linux-gnu
    python3 -m pip install --user futoin-cid
    pip install futoin-cid==0.8.3
    pip install futoin-cid
    ~/.local/bin/cid prepare
    ~/.local/bin/cid build
}

askSwap() {
    echo ""
    echo "Would you like to configure your filewall?"
    read MNCOUNT
}

AskCount() {
    #ask for mn count
}

askIp() {
    #ask the user for there ip(s)
}

askFirewall() {
    echo ""
    echo "Would you like to configure your filewall?"
    read MNCOUNT
}

askSentinel() {
    #not needed for now, possibly in the future.
}

main() {
    #do it all here
}

#!/bin/bash

cd ~
echo "****************************************************************************"
echo "* Ubuntu 18.04 is the recommended operating system for this install.       *"
echo "*                                                                          *"
echo "* This script will install and configure your GENIX masternodes.           *"
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
    sudo apt-get -y update
    sudo apt-get -y upgrade
    sudo apt-get -y install git
    sudo apt install -y python3-pip
    sudo apt install -y python-pip
    sudo apt-get install -y curl
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

    mkdir dash-fork
    cd dash-fork
    git clone https://github.com/akshaynexus/pigeoncoin-dash
    cd pigeoncoin-dash
    export HOST=x86_64-linux-gnu
    python3 -m pip install --user futoin-cid
    pip install futoin-cid==0.8.3
    pip install futoin-cid
    ~/.local/bin/cid prepare
    ~/.local/bin/cid build
    rm /usr/bin/pigeon*
    mv build/pigeon/bin/pigeond /usr/bin
    mv build/pigeon/bin/pigeon-cli /usr/bin
    mv build/pigeon/bin/pigeon-tx /usr/bin
    rm -r /root/dash-fork/pigeoncoin-dash/

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
    CONF_DIR=~/.pigeoncore_$ALIAS

    # Create scripts
    echo '#!/bin/bash' >~/bin/pigeond_$ALIAS.sh
    echo "pigeond -daemon -conf=$CONF_DIR/pigeon.conf -datadir=$CONF_DIR "'$*' >>~/bin/pigeond_$ALIAS.sh
    echo '#!/bin/bash' >~/bin/pigeon-cli_$ALIAS.sh
    echo "pigeon-cli -conf=$CONF_DIR/pigeon.conf -datadir=$CONF_DIR "'$*' >>~/bin/pigeon-cli_$ALIAS.sh
    echo '#!/bin/bash' >~/bin/pigeon-tx_$ALIAS.sh
    echo "pigeon-tx -conf=$CONF_DIR/pigeon.conf -datadir=$CONF_DIR "'$*' >>~/bin/pigeon-tx_$ALIAS.sh
    chmod 755 ~/bin/pigeon*.sh

    mkdir -p $CONF_DIR
    echo "testnet=1"
    echo ""
    echo "[test]"
    echo "rpcuser=user"$(shuf -i 100000-10000000 -n 1) >>pigeon.conf_TEMP
    echo "rpcpassword=pass"$(shuf -i 100000-10000000 -n 1) >>pigeon.conf_TEMP
    echo "rpcallowip=127.0.0.1" >>pigeon.conf_TEMP
    echo "rpcport=$RPCPORT" >>pigeon.conf_TEMP
    echo "listen=1" >>pigeon.conf_TEMP
    echo "server=1" >>pigeon.conf_TEMP
    echo "daemon=1" >>pigeon.conf_TEMP
    echo "port=$PORT" >>pigeon.conf_TEMP
    echo "externalip=$IP" >>pigeon.conf_TEMP
    echo "bind=$IP" >>pigeon.conf_TEMP
    echo "logtimestamps=1" >>pigeon.conf_TEMP
    echo "maxconnections=64" >>pigeon.conf_TEMP
    echo "" >>pigeon.conf_TEMP

    echo "addnode=138.68.75.8:18765" >>pigeon.conf_TEMP
    echo "addnode=159.89.177.213:18765" >>pigeon.conf_TEMP
    echo "addnode=86.3.228.217:18765" >>pigeon.conf_TEMP
    echo "addnode=213.136.83.223:18765" >>pigeon.conf_TEMP
    echo "addnode=45.63.99.59:18765" >>pigeon.conf_TEMP

    echo "" >>pigeon.conf_TEMP
    echo "masternodeprivkey=$PRIVKEY" >>pigeon.conf_TEMP
    sudo ufw allow $PORT/tcp

    mv pigeon.conf_TEMP $CONF_DIR/pigeon.conf

    sh ~/bin/pigeond_$ALIAS.sh
done

echo "Do you want to install sentinel? (no if you did it before) [y/n]"
read SENTINELSETUP

if [[ $SENTINELSETUP =~ "y" ]]; then
    echo "Starting sentinel setup.."

    version=$(python -V 2>&1 | grep -Po '(?<=Python )(.+)')
    parsedVersion=$(echo "${version//./}")
    new=$(tr -dc '0-9' <<<$parsedVersion | cut -c1-4)

    if [[ "$new" -lt "3000" && "$new" -gt "2700" ]]; then
        echo "Valid version skipping py installation..."
    else
        echo "Invalid version installing py..."
        sudo apt-get install -y python
    fi

    cd ~

    sudo apt-get -y install virtualenv

    git clone https://github.com/genix-project/sentinel.git

    echo "setting up sentinel..."

    echo "dash_conf=$CONF_DIR/genix.conf" >>sentinel.conf_TEMP
    echo "network=mainnet" >>sentinel.conf_TEMP
    echo "db_name=database/sentinel.db" >>sentinel.conf_TEMP
    echo "db_driver=sqlite" >>sentinel.conf_TEMP

    mv sentinel.conf_TEMP $HOME/sentinel/sentinel.conf

    cd ~/sentinel

    virtualenv ./venv
    ./venv/bin/pip install -r requirements.txt
    crontab -l | {
        cat
        echo "* * * * * cd /root/sentinel/ && ./venv/bin/python bin/sentinel.py >/dev/null 2>&1"
    } | crontab -
    echo "all done"
fi
