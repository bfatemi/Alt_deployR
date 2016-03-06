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

deployR="https://deployr.revolutionanalytics.com/download/bundles/release/DeployR-Open-Linux-8.0.0.tar.gz"
dl_dir="/home/deployr-user/deployrdownload"
mkdir $dl_dir

#read -p "Exit here and check to make sure $dl_dir has been created" tmp

pushd $dl_dir
curl $deployR | tar xz | pv -tpe -N "Downloading DeployR" > /dev/null
pushd installFiles
#./installDeployROpen.sh
./installDeployROpen.sh --no-ask --nolicense
popd
popd


#update groovy before install
#add JAVA_HOME declaration to installFiles/config/configure.sh
#update installFiles/properties for JAVA_PATH and JAVA_HOME
#update java_path in tomcat/tomcat7.sh


# weird observations:

#after installation, run this:
#sudo netstat -lpn |grep :80

#to see that mongod is correctly on port 0.0.0.0:8003
#rserve is correctly here: 0.0.0.0:8004 and here 0.0.0.0:8005

#those two are on tcp

#however, java acts weird. tomcat can start fine and binds to
#tcp 6 :::8000 this is the java process that starts tomcat
#the one that stops tomcat doesnt initially bind. it takes a really long time to finally appear here:
#127.0.0.1:8002
#the third java process binds here also after a delay :::8006
