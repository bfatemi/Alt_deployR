clean(){
        apt-get --yes update
        apt-get --yes upgrade
        apt-get -f install
        apt-get --yes clean
}

install(){
        sudo apt-get --yes install $1
}

########################################################################
# Build Essentials
########################################################################

clean

install curl
install build-essential
install liblzma-dev
install libcurl4-openssl-dev
install libpcre3-dev
install liblzma-dev
install zlib1g-dev

#sudo apt-get --yes install curl
#sudo apt-get --yes install build-essential
#sudo apt-get --yes install liblzma-dev
#sudo apt-get --yes install libcurl4-openssl-dev
#sudo apt-get --yes install libpcre3-dev
#sudo apt-get --yes install liblzma-dev
#sudo apt-get --yes install zlib1g-dev

echo
read -p "...Updates and build essentials done... Press enter" tmp
clear

########################################################################
# Install Dependancies
########################################################################

read -p "continue" tmp

#sudo apt-get install --yes make gcc gfortran nfs-common
clean

install make
install gcc
install gfortran
install nfs-common

echo
read -p "...Dependencies installed... Press enter to install and set JAVA_HOME"
clear

# install java
install default-jdk
echo
#sudo apt-get --yes install default-jdk

########################################################################
# Set JAVA_HOME
########################################################################

read -p "continue" tmp
update-alternatives --config java

read -p "...Java Installed... Enter JAVA_HOME: " jhome
printf "%s\n" "export JAVA_HOME=$jhome" >> ~/.bashrc
source ~/.bashrc

read -p "JAVA_HOME set to: $JAVA_HOME\nPress enter to install R and MLK..." tmp
clear

########################################################################
# Install RRO
########################################################################

clean

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

read -p "...RRO and MLK installed...Press enter to exit and test RRO" tmp
clear

#run R
R
exit 0

