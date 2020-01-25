#!/bin/bash

cd ~
echo "****************************************************************************"
echo "* Ubuntu 18.04 shell script meant to speed up setting up new servers       *"
echo "*                                                                          *"
echo "*                                                                          *"
echo "****************************************************************************"
echo && echo && echo

echo "Do you want to install dependencies? [y/n]"
read DOSETUP

if [[ $DOSETUP =~ "y" ]] ; then
  sudo apt-get update
  sudo apt-get -y upgrade
  sudo apt-get -y dist-upgrade
  sudo apt-get install -y nano htop git
  sudo apt-get install -y software-properties-common
  sudo apt-get install -y build-essential libtool autotools-dev pkg-config libssl-dev
  sudo apt-get install -y libboost-all-dev
  sudo apt-get install -y libboost-system-dev
  sudo apt-get install -y libzmq3-dev
  sudo apt-get install -y libevent-dev
  sudo apt-get install -y libminiupnpc-dev
  sudo apt-get install -y autoconf
  sudo apt-get install -y automake unzip
  sudo add-apt-repository  -y  ppa:bitcoin/bitcoin
  sudo apt-get update
  sudo apt-get install -y libdb4.8-dev libdb4.8++-dev
fi

echo && echo && echo 

echo "Do you want to set up a swapfile? [y/n]"
read SWAPSETUP
if [[ $SWAPSETUP =~ "y" ]] ; then
  cd /var
  sudo touch swap.img
  sudo chmod 600 swap.img
  sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=2000
  sudo mkswap /var/swap.img
  sudo swapon /var/swap.img
  sudo free
  sudo echo "/var/swap.img none swap sw 0 0" >> /etc/fstab
  cd

fi
