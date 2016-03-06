
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

########################################################################
# Install Dependancies
########################################################################

apt-get --yes upgrade
apt-get --yes clean

install make
install gcc
install gfortran
install nfs-common
install default-jdk

########################################################################
# Install RRO
########################################################################

RRO_322="https://mran.revolutionanalytics.com/install/RRO-3.2.2-Ubuntu-14.4.x86_64.deb"

wget $RRO_322
dpkg -i RRO-3.2.2-Ubuntu-14.4.x86_64.deb > /dev/null 2>&1
if [ $? -gt 0 ]; then
        apt-get -f --force-yes --yes install > /dev/null 2>&1
fi
dpkg -i RRO-3.2.2-Ubuntu-14.4.x86_64.deb > /dev/null 2>&1

########################################################################
# Install MLK
########################################################################

MLK_322="https://mran.revolutionanalytics.com/install/RevoMath-3.2.2.tar.gz"
curl $MLK_322 | tar xz

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
