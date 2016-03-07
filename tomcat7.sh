#!/bin/bash
# description: Tomcat Server basic start/shutdown script
# processname: tomcat
JAVA_HOME=/usr/lib/jvm/jre1.8.0_73/bin/java
export JAVA_HOME

TOMCAT_HOME=$INSTALL_FOLDER$/tomcat/tomcat7/bin
START_TOMCAT=$INSTALL_FOLDER$/tomcat/tomcat7/bin/startup.sh
STOP_TOMCAT=$INSTALL_FOLDER$/tomcat/tomcat7/bin/shutdown.sh
VERSION=$VERSION$
#. /etc/rc.d/init.d/functions
start() {
echo -n "Starting tomcat: "
cd $TOMCAT_HOME
${START_TOMCAT}
echo "done."
}
stop() {
echo -n "Shutting down tomcat: "
cd $TOMCAT_HOME
${STOP_TOMCAT}
sleep 2
ps -ef | grep ${VERSION}\/tomcat\/tomcat7 | grep -v grep | awk '{print $2}' | xargs kill -15 > null 2>&1
echo "done."
}
case "$1" in
start)
start
;;
stop)
stop
;;
restart)
stop
sleep 20
start
;;
*)
echo "Usage: $0 {start|stop|restart}"
esac
exit 0
~                                                                               
~                                                                               
~                                                                               
~                                                                               
~                                                                               
~                                                                               
~                                                                               
~                                                                               
~                                                                               
~                                                                               
~                                                                               
~                                                                               
~                                                                               
~                                                                               
~                                                                               
~                                                                               
~                                                                               
                                                              1,1           All

