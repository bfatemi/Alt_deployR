clean(){
        #apt-get -f install
        apt-get --yes upgrade
        apt-get --yes clean
}

install(){
        sudo apt-get --yes install $1
}

########################################################################
# Build Essentials
########################################################################


apt-get --yes update
clean

install curl
install build-essential
install liblzma-dev
install libcurl4-openssl-dev
install libpcre3-dev
install liblzma-dev
install zlib1g-dev

echo
echo
echo
echo
read -p "...Updates and build essentials done... Press enter" tmp
clear

########################################################################
# Install Dependancies
########################################################################

clean
install make
install gcc
install gfortran
install nfs-common
install default-jdk

echo
echo
echo
echo
read -p "...Dependencies installed... Press enter to install RRO and MLK"
clear

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

echo
echo
echo
echo
read -p "...RRO and MLK installed...Press enter to install deployrRserve" tmp
clear

########################################################################
# Install DeployrRserve
########################################################################

deployrRserve="https://github.com/deployr/deployr-rserve/releases/download/v7.4.2/deployrRserve_7.4.2.tar.gz"
wget $deployrRserve
R CMD INSTALL deployrRserve_7.4.2.tar.gz

echo
echo
echo
echo
read -p "...deployrRserve installed...all dependencies installed...Press enter to exit and test R" tmp
clear
#run R
R
exit 0

########################################################################
# Set JAVA_HOME
########################################################################

#update-alternatives --config java

#read -p "Enter JAVA_HOME: " jhome
#printf "%s\n" "export JAVA_HOME=$jhome" >> ~/.bashrc
#source ~/.bashrc

#read -p "JAVA_HOME set to: $JAVA_HOME\nPress enter to install R and MLK..." tmp
#clear
