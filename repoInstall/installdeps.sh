#!/bin/bash

install(){
        sudo apt-get --yes install $1
}

########################################################################
# Build Essentials
########################################################################

apt-get --yes update
apt-get --yes upgrade
apt-get --yes clean

install curl
install build-essential
install liblzma-dev
install libcurl4-openssl-dev
install libpcre3-dev
install liblzma-dev
install zlib1g-dev

# Install Dependancies
install make
install gcc
install gfortran
install nfs-common
#install default-jdk

apt-get --yes upgrade
apt-get --yes clean


########################################################################
# Install JAVA
########################################################################

jdir="/usr/lib/jvm"
mkdir $jdir
pushd $jdir
wget "https://github.com/bfatemi/DeployR/releases/download/v0.2/jre-8u73-linux-x64.gz"
tar zxvf jre-8u73-linux-x64.gz
popd

JAVA_HOME="$jdir/jre1.8.0_73"
JAVA_PATH="$JAVA_HOME/bin/java"
printf "%s\n" "export JAVA_HOME=$JAVA_HOME" >> ~/.bashrc
source ~/.bashrc

update-alternatives --install /usr/bin/java java $JAVA_PATH 100

########################################################################
# Install RRO
########################################################################

RRO_322="https://github.com/bfatemi/DeployR/releases/download/v0.2/RRO-3.2.2-Ubuntu-14.4.x86_64.deb"

wget $RRO_322
dpkg -i RRO-3.2.2-Ubuntu-14.4.x86_64.deb > /dev/null 2>&1
if [ $? -gt 0 ]; then
        apt-get -f --force-yes --yes install > /dev/null 2>&1
fi
dpkg -i RRO-3.2.2-Ubuntu-14.4.x86_64.deb > /dev/null 2>&1

########################################################################
# Install MLK
########################################################################

MLK_322="https://github.com/bfatemi/DeployR/releases/download/v0.2/NinjaQuant-RevoMath322.tar.gz"
wget $MLK_322
tar zxvf RevoMath-3.2.2.tar.gz

pushd RevoMath/
sudo ./RevoMath.sh
popd

########################################################################
# Install DeployrRserve
########################################################################

deployrRserve="https://github.com/deployr/deployr-rserve/releases/download/v7.4.2/deployrRserve_7.4.2.tar.gz"
wget $deployrRserve
R CMD INSTALL deployrRserve_7.4.2.tar.gz

#run R
clear
R
exit 0

