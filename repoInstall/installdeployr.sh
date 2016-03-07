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

pushd "deployrdownload/installFiles"
sudo ./installDeployROpen.sh --no-ask --nolicense

IP=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
echo 'y' | /opt/deployr/8.0.0/deployr/tools/setWebContext.sh -ip $IP
popd
popd

##################################################################
# DeployR is installed, but now set the webcontext because this
# is a remote server
##################################################################



#update tomcat7.sh to export JAVA_HOME
#update properties.sh to export JAVA_HOME

#these programs should not export JAVA_HOME. there should be a link to the latest and these should export that. If I update java in the future, these will export the wrong java anytime I start/stop the server


#after installation, run this:
#sudo netstat -lpn |grep :80

