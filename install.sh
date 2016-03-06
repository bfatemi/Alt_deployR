#!/bin/bash
if [ $# -lt 2 ] ; then
echo "Usage: LinuxScripts/installTomcat.sh redhat|sles {download_directory_path} {install_directory_path} [{tomcat_port}]  [{tomcat_ssl_port}]  [{tomcat_shutdown_port}]"
echo "Example: LinuxScripts/installTomcat.sh redhat /home/deployr-user/deployrdownload /home/deployr-user/deployr/8.0"
exit -1
fi

RETVAL=0

LINUX=$1
PWDD=$2
INSTALL_FOLDER=$3

TOMCAT_VERSION=7.0.64
TOMCAT_PORT=8000
TOMCAT_SSL_PORT=8001
TOMCAT_SHUTDOWN_PORT=8002
IS_ROOT=0
USER=apache
EDITION=enterprise

if [[ ! -z $4 ]]; then
   TOMCAT_PORT=$4 
fi
if [[ ! -z $5 ]]; then
   TOMCAT_SSL_PORT=$5 
fi
if [[ ! -z $6 ]]; then
   TOMCAT_SHUTDOWN_PORT=$6 
fi
if [[ ! -z $7 ]]; then
   IS_ROOT=$7 
fi
if [[ ! -z $8 ]]; then
   USER=$8 
fi
if [[ ! -z $9 ]]; then
   EDITION=$9 
fi

if [ ! -e $INSTALL_FOLDER/tomcat ] ; then

## Create tomcat directories. 
                mkdir $INSTALL_FOLDER/tomcat  >> $PWDD/install_log.txt 2>&1
                if [ $? -ne 0 ] ; then
                        echo "Unable to create tomcat folder at $INSTALL_FOLDER/tomcat" | tee -a $PWDD/install_log.txt 2>&1
                	exit -1
            	fi
            	mkdir -p $INSTALL_FOLDER/www/apps  >> $PWDD/install_log.txt 2>&1

## Change directory to tomcat. 
                cd $INSTALL_FOLDER/tomcat >> $PWDD/install_log.txt 2>&1

## Untar the Tomcat files.
		tar -xzf $PWDD/installFiles/tomcat/apache-tomcat-$TOMCAT_VERSION.tar.gz >> $PWDD/install_log.txt 2>&1
                if [ $? -ne 0 ] ; then
                        echo "Error with tomcat tar file - $PWDD/installFiles/tomcat/apache-tomcat-$TOMCAT_VERSION.tar.gz" | tee -a $PWDD/install_log.txt 2>&1
                	exit -1
            	fi

## Extract and install the Tomcat files.
		ln -s apache-tomcat-$TOMCAT_VERSION tomcat7 >> $PWDD/install_log.txt 2>&1
                if [ $? -ne 0 ] ; then
                        echo "Error with tomcat ln command" | tee -a $PWDD/install_log.txt 2>&1
                	exit -1
            	fi

## remove all files/folders from webapps
                rm -rf $INSTALL_FOLDER/tomcat/tomcat7/webapps/*

## copy jar file to tomcat lib
                cd $PWDD/installFiles/tomcat >> $PWDD/install_log.txt 2>&1
                cp h2-1.3.173.jar $INSTALL_FOLDER/tomcat/tomcat7/lib >> $PWDD/install_log.txt 2>&1
                cp testJava.sh $INSTALL_FOLDER/tomcat/tomcat7/bin >> $PWDD/install_log.txt 2>&1
                cp tomcat-attribution.txt $INSTALL_FOLDER/tomcat/tomcat7 >> $PWDD/install_log.txt 2>&1

## Create tomcat startup script and replace the $INSTALL_FOLDER$ variable with the actual installation directory path.
                cp tomcat7.sh $INSTALL_FOLDER/tomcat/tomcat7.sh >> $PWDD/install_log.txt 2>&1
                sed -i -e "s/\\\$INSTALL_FOLDER\\\$/$(echo $INSTALL_FOLDER | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/g" $INSTALL_FOLDER/tomcat/tomcat7.sh >> $PWDD/install_log.txt 2>&1
                if [ $IS_ROOT -eq 1 ] ; then
                    if [ "$LINUX" == "redhat" ] ; then
                        sed -i -e "s/\\\${START_TOMCAT}/$(echo daemon --user \"$USER\" \${START_TOMCAT}  | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/g" $INSTALL_FOLDER/tomcat/tomcat7.sh >> $PWDD/install_log.txt 2>&1
                        sed -i -e "s/#. \/etc\/rc.d\/init.d\/functions/$(echo . \/etc\/rc.d\/init.d\/functions | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/g" $INSTALL_FOLDER/tomcat/tomcat7.sh >> $PWDD/install_log.txt 2>&1
                    elif [ "$LINUX" == "ubuntu" ] ; then
                        sed -i -e "s/\\\${START_TOMCAT}/$(echo start-stop-daemon --start --user \"$USER\" --chuid \"$USER\" --chdir $INSTALL_FOLDER/tomcat/tomcat7/bin --exec \${START_TOMCAT}  | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/g" $INSTALL_FOLDER/tomcat/tomcat7.sh >> $PWDD/install_log.txt 2>&1
                    else
                        sed -i -e "s/\\\${START_TOMCAT}/$(echo start_daemon -u \"$USER\" \${START_TOMCAT}  | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/g" $INSTALL_FOLDER/tomcat/tomcat7.sh >> $PWDD/install_log.txt 2>&1
                    fi
                fi
                chmod +x $INSTALL_FOLDER/tomcat/tomcat7.sh >> $PWDD/install_log.txt 2>&1
        fi

## change shebang from sh to bash
sed -i -e '1s/sh/bash/' $INSTALL_FOLDER/tomcat/tomcat7/bin/catalina.sh

## Edit catalina.sh to define several environment variables. 
	grepout=`grep -i "REVODEPLOYR8_0_HOME" $INSTALL_FOLDER/tomcat/tomcat7/bin/catalina.sh`
	if [ 0 -eq ${#grepout} ] ; then
                echo "sed $INSTALL_FOLDER/tomcat/tomcat7/bin/catalina.sh" >> $PWDD/install_log.txt 2>&1
		sed -i -e "1 a\
DEPLOYR_JAVA_HOME=$JAVA_HOME\n\
REVODEPLOYR8_0_HOME=${INSTALL_FOLDER}/deployr\n\
CATALINA_HOME=${INSTALL_FOLDER}/tomcat/tomcat7\n\
export CATALINA_HOME\n\
export REVODEPLOYR8_0_HOME\n\
source \$CATALINA_HOME/bin/testJava.sh\n\
isJavaValid\n\
if [ \$? -ne 0 ]; then\n\
exit -1\n\
fi" -e "/Execute The Requested Command/ i\
JAVA_OPTS=\"\$JAVA_OPTS -DdeployrEdition=$EDITION -Djava.awt.headless=true -server -Xms1024m -Xmx1024m -XX:MaxPermSize=128m\"
" $INSTALL_FOLDER/tomcat/tomcat7/bin/catalina.sh >> $PWDD/install_log.txt 2>&1
	fi

## Edit server.xml to update port numbers with the arguments defined when the script was run, replace and add some lines.
	grepout=`grep -i "\/www\/apps" $INSTALL_FOLDER/tomcat/tomcat7/conf/server.xml`
	if [ 0 -eq ${#grepout} ] ; then

sed -i -e "/<.Host>/ i      <Context docBase=\"$(echo $INSTALL_FOLDER | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/www/apps\" path=\"/apps\"/>" \
$INSTALL_FOLDER/tomcat/tomcat7/conf/server.xml >> $PWDD/install_log.txt 2>&1

sed -i -e '/\<Connector port="8008" protocol/ s/AJP\/1.3/org.apache.coyote.ajp.AjpNioProtocol/' \
-e '/\<Connector port="8080" protocol/ s/HTTP\/1.1/org.apache.coyote.http11.Http11NioProtocol" \
               compression="1024" \
               compressableMimeType="text\/html,text\/xml,text\/json,text\/plain,application\/xml,application\/json,image\/svg+xml/' \
-e '/\<Connector port="8443" protocol/ s/HTTP\/1.1/org.apache.coyote.http11.Http11NioProtocol" \
               compression="1024" \
               compressableMimeType="text\/html,text\/xml,text\/json,text\/plain,application\/xml,application\/json,image\/svg+xml/' \
-e "s/sslProtocol=\"TLS\"/$(echo sslProtocol=\"TLS\" keystoreFile=\"$INSTALL_FOLDER\/tomcat\/tomcat7\/.keystore\" | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/g" \
$INSTALL_FOLDER/tomcat/tomcat7/conf/server.xml >> $PWDD/install_log.txt 2>&1
sed -i -e "s/8443/$(echo $TOMCAT_SSL_PORT | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/g" \
-e "s/8005/$(echo $TOMCAT_SHUTDOWN_PORT | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/g" \
-e "s/8080/$(echo $TOMCAT_PORT | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/g" \
-e '/Connector port="8009"/d' \
$INSTALL_FOLDER/tomcat/tomcat7/conf/server.xml >> $PWDD/install_log.txt 2>&1

## update web.xml

sed -i -e "/<\/web-app>/i\
<!--\n\
<security-constraint>\n\
  <web-resource-collection>\n\
      <web-resource-name>HTTPSOnly</web-resource-name>\n\
      <url-pattern>/*</url-pattern>\n\
  </web-resource-collection>\n\
  <user-data-constraint>\n\
      <transport-guarantee>CONFIDENTIAL</transport-guarantee>\n\
  </user-data-constraint>\n\
</security-constraint>\n\
<security-constraint>\n\
  <web-resource-collection>\n\
      <web-resource-name>HTTPSOrHTTP</web-resource-name>\n\
      <url-pattern>*.ico</url-pattern>\n\
      <url-pattern>/img/*</url-pattern>\n\
      <url-pattern>/css/*</url-pattern>\n\
  </web-resource-collection>\n\
  <user-data-constraint>\n\
      <transport-guarantee>NONE</transport-guarantee>\n\
  </user-data-constraint>\n\
</security-constraint>\n\
-->" $INSTALL_FOLDER/tomcat/tomcat7/conf/web.xml


            echo "Tomcat7 configured"
	fi
exit $RETVAL
