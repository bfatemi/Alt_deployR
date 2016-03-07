#!/bin/bash
EDITION=community
RETVAL=0
NODE=0
DATABASE_SERVER_NAME="localhost"
DATABASE_PORT="8003"
REMOTE_DATA_BASE=local
INSTALL_FOLDER=""
ERROR_OK=0
SILENT_MODE=0
IP=""
VERSION=8.0
MINOR_VERSION=0
REVO_VERSION=8.0.0
REVO_BIN_STRING=Revo-$VERSION
R_VERSION=R-3.1.2
LINUX_VERSION=5
TOMCAT_VERSION=7.0.64
TOMCAT_SSL_PORT=8001
TOMCAT_PORT=8000
TOMCAT_SHUTDOWN_PORT=8002
RSERVE_PORT=8004
RSERVE_CANCEL_PORT=8005
USER=`whoami`
GROUP=`id -g -n $USER`
IS_ROOT=0
R=1
RBIN="/usr/bin/R"
R_HOME=/usr/lib64/R
DB_PATH=""
HOST_NAME=localhost
NOASK="true"
DEBUG_LOGS="true"
NOLICENSE="true"
LINUX=ubuntu

checkRoot() {
	uid=`id -u`
        if [ 0 -eq $uid ] ; then
        	IS_ROOT=1
            	USER=apache
            	GROUP=apache
            	grepout=`grep -i "^apache" /etc/passwd`
            	if [ 0 -eq ${#grepout} ] ; then
               		useradd apache >>/dev/null 2>&1
               		usermod -s /sbin/nologin apache  >> $PWDD/install_log.txt 2>&1
            	fi
            	grepout=`grep -i "^apache" /etc/group`
            	if [ 0 -eq ${#grepout} ] ; then
               		groupadd apache >>/dev/null 2>&1
            	fi
        	INSTALL_FOLDER=/opt/deployr/$VERSION.$MINOR_VERSION
        else
            	IS_ROOT=0
            	INSTALL_FOLDER=$HOME/deployr/$VERSION.$MINOR_VERSION
        fi
}

start() {

	echo "JAVA_HOME= $JAVA_HOME"
	read tmp
	
	checkRoot

	################################
	##### Check prerequisites  #####
	################################

	analyzeJava
	if [ $? != 0 ] ; then
		exitWithError -1
	fi

	analyzeR open $NOASK
	if [ $? != 0 ] ; then
		exitWithError -1
	fi

	analyzeRserve $PWDD/installFiles/rserve
	if [ $? != 0 ] ; then
		exitWithError -1
	fi
	
	################################
        ##### mk dir and get mongo #####
        ################################

	mkdir -p $INSTALL_FOLDER
	getMongodbpath
	
	##############################
	##### Install the server #####
	##############################

	configureRserve
        installMongo
        installTomcat
        configureDeployrServer
        installShellScripts
        
	##############################
        ### DONE- Restart and exit ###
        ##############################
	out "Starting Rserve and Tomcat. This may take a moment." | tee -a $PWDD/install_log.txt 2>&1

	#pushd $INSTALL_FOLDER
        $INSTALL_FOLDER/tomcat/tomcat7.sh start >> $PWDD/install_log.txt 2>&1
        #cd $INSTALL_FOLDER
        $INSTALL_FOLDER/rserve/rserve.sh start >> $PWDD/install_log.txt 2>&1
	#exitCode=$?
	
	echo "Installation is complete:" | tee -a $PWDD/install_log.txt 2>&1
	echo "http://$HOST_NAME:$TOMCAT_PORT/deployr/landing" | tee -a $PWDD/install_log.txt 2>&1
	echo "Default password for 'admin' and 'testuser' accounts: 'changeme'" | tee -a $PWDD/install_log.txt 2>&1	
        #exitProgram $exitCode
	
}

set_webcontext() {
WEBCONTEXT="http://${IP}:$TOMCAT_PORT/deployr"
$INSTALL_FOLDER/mongo/mongo/bin/mongo deployr -u deployr -p $MONGO_PASSWORD$ --host $HOST --port ${PORT}03 << FOO > /dev/null 2>&1
db.server.update( {}, {\$set: {webContext: '$WEBCONTEXT'}} )
exit
FOO
}

getMongodbpath() {
        DB_PATH=${INSTALL_FOLDER}/deployr/database

	## check user has permissions to write to dbpath
        mkdir -p $DB_PATH >> $PWDD/install_log.txt 2>&1

        if [ $IS_ROOT -eq 1 ] ; then
                    cd $DB_PATH
                    cd ..
                    chown -R $USER.$GROUP *
                    chmod -R 775 *
        fi
	
	## get full path in case it's a relative path
        DB_PATH=`cd "$DB_PATH"; pwd`
}


configureRserve() {
        cd $PWDD/installFiles
        rserve/configure.sh $LINUX $PWDD $INSTALL_FOLDER $USER $GROUP $RRE_PATH $RSERVE_PATH $IS_ROOT $RSERVE_VERSION
        RETVAL=$?
        if [ $RETVAL -ne 0 ] ; then
                exitWithError $RETVAL
        fi
        echo "Rserve installed" >> $PWDD/install_log.txt 2>&1
}

installMongo() {
        cd $PWDD/installFiles
        mongo/install.sh $LINUX $PWDD $INSTALL_FOLDER $DB_PATH $USER $GROUP $HOST_NAME  $DATABASE_SERVER_NAME $REMOTE_DATA_BASE $TOMCAT_PORT $DATABASE_PORT $IS_ROOT
 
	RETVAL=$?
        if [ $RETVAL -ne 0 ] ; then
                echo "Error in installMongo" | tee -a $PWDD/install_log.txt 2>&1
                exitWithError $RETVAL
        fi
        echo "Mongo installed" >> $PWDD/install_log.txt 2>&1
}

installTomcat() {
        cd $PWDD/installFiles
        tomcat/install.sh $LINUX $PWDD $INSTALL_FOLDER $TOMCAT_PORT $TOMCAT_SSL_PORT $TOMCAT_SHUTDOWN_PORT $IS_ROOT $USER $EDITION
        RETVAL=$?
        if [ $RETVAL -ne 0 ] ; then
                echo "Error in installTomcat"
                exitWithError $RETVAL
        fi
        echo "tomcat configured" >> $PWDD/install_log.txt 2>&1
}

configureDeployrServer() {
        cd $PWDD/installFiles
        config/configure.sh $PWDD $INSTALL_FOLDER $RBIN $NODE $REMOTE_DATA_BASE $DATABASE_SERVER_NAME $DEBUG_LOGS $EDITION $IS_ROOT $HOST_NAME
        RETVAL=$?
        if [ $RETVAL -ne 0 ] ; then
                echo "Error in configureDeployrServer"
                exitWithError $RETVAL
        fi
        echo "DeployR server configured" >> $PWDD/install_log.txt 2>&1
}

installShellScripts() {
        cd $PWDD/installFiles
        tools/installShellScripts.sh $PWDD $INSTALL_FOLDER $REMOTE_DATA_BASE $NODE
        RETVAL=$?
        if [ $RETVAL -ne 0 ] ; then
                echo "Error in installShellScripts"  | tee -a $PWDD/install_log.txt 2>&1
                exitWithError $RETVAL
        fi
        echo "Startup/Shutdown shell scripts installed" >> $PWDD/install_log.txt 2>&1
}

exitWithError() {
	killall -9 $INSTALL_FOLDER/mongo/mongo/bin/mongod
	cd $PWDD
	rm -rf $INSTALL_FOLDER >> $PWDD/install_log.txt 2>&1
	echo "refer to ${PWDD}/install_log.txt for details"
	exit $1
}

cd ../
PWDD=`pwd`
source $PWDD/installFiles/properties.sh

#Check JAVA_HOME
if [ -z "${JAVA_HOME}" ] ; then
      echo "JAVA_HOME not set"
      exit -1
fi

source $PWDD/installFiles/R/findR.sh $PWDD/installFiles/R
source $PWDD/installFiles/rserve/findRserve.sh $PWDD/installFiles/rserve

rm $PWDD/install_log.txt
cd installFiles >> $PWDD/install_log.txt 2>&1

start "$@"


