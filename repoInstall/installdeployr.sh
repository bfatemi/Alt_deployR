#!/bin/bash

##################################################################
# Adding dedicated R group and user
##################################################################

deployrUser=deployr-user
deployrPassword=Newyork1
deployrGroup=deployr-group

sudo addgroup $deployrGroup
echo -e "$deployrPassword\n$deployrPassword" | \
sudo adduser --ingroup $deployrGroup $deployrUser
sudo adduser $deployrUser sudo

##################################################################
# Installing DeployR
##################################################################

deployR="https://github.com/bfatemi/DeployR/releases/download/v0.2/NinjaQuant-deployr800.tar.gz"
dl_dir="/home/deployr-user/deployrdownload"

pushd "/home/deployr-user"
wget $deployR
mkdir "deployrdownload"
tar zxvf "NinjaQuant-deployr800.tar.gz"

pushd installFiles
sudo /installDeployROpen.sh --no-ask --nolicense
popd

popd

#update tomcat7.sh to export JAVA_HOME
#update properties.sh to export JAVA_HOME

#these programs should not export JAVA_HOME. there should be a link to the latest and these should export that. If I update java in the future, these will export the wrong java anytime I start/stop the server

#investigate why process takes so long to bind to 8006 and 8002
#"" why groovy looks the way it does


#after installation, run this:
#sudo netstat -lpn |grep :80

