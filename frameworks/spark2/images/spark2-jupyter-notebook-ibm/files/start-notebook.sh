#!/usr/bin/env bash

set -x

cat /opt/spark-defaults.conf | sed -e "s/XXX_DRIVER_MEMORY/$SPARK_DRIVER_RAM/" > ${SPARK_HOME}/conf/spark-defaults.conf
#cat /opt/core-site.xml | sed -e "s/XXX_NAMENODE_HOST/$NAMENODE_HOST/" > ${HADOOP_HOME}/etc/hadoop/core-site.xml
cp /opt/hdfs-site.xml ${HADOOP_HOME}/etc/hadoop/

#HADOOP_USER_NAME=root /opt/hadoop/bin/hdfs dfs -mkdir /user/$NB_USER
#HADOOP_USER_NAME=root /opt/hadoop/bin/hdfs dfs -chown $NB_USER /user/$NB_USER
#HADOOP_USER_NAME=root /opt/hadoop/bin/hdfs dfs -chmod 750 /user/$NB_USER

cd $HOME/work

exec jupyter notebook $*

exit

