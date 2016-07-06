#!/usr/bin/env bash

set -x

#mkdir -p /etc/hadoop/conf/
#cat /opt/core-site.xml | sed -e "s/XXX_NAMENODE_HOST/$NAMENODE_HOST/" > /etc/hadoop/conf/core-site.xml
#cp /opt/hdfs-site.xml /etc/hadoop/conf/


cat /opt/spark-defaults.conf | sed -e "s/XXX_DRIVER_MEMORY/$SPARK_DRIVER_RAM/" | sed -e "s/XXX_EXECUTOR_MEMORY/${SPARK_EXECUTOR_RAM}/" | sed -e "s#XXX_MASTER#${SPARK_MASTER}#" > ${SPARK_HOME}/conf/spark-defaults.conf
#echo -e "HADOOP_CONF_DIR=/etc/hadoop/conf" > ${SPARK_HOME}/conf/spark-env.sh


if getent passwd $NB_USER; then
	echo "User $NB_USER already exists"
else
	useradd -m -s /bin/bash -N $NB_USER
fi

/opt/hadoop/bin/hdfs dfs -mkdir /user/$NB_USER
/opt/hadoop/bin/hdfs dfs -chown $NB_USER /user/$NB_USER
/opt/hadoop/bin/hdfs dfs -chmod 750 /user/$NB_USER

mkdir /home/$NB_USER/work
mkdir /home/$NB_USER/.jupyter
mkdir /home/$NB_USER/.local
mkdir -p /home/$NB_USER/.ipython/profile_default/startup/

cp -a /home/nbuser/.jupyter /home/$NB_USER
cp -a /home/nbuser/.local /home/$NB_USER
cp -a /home/nbuser/.ipython /home/$NB_USER

chown -R $NB_USER /home/$NB_USER/work /home/$NB_USER/.jupyter /home/$NB_USER/.local /home/$NB_USER/.ipython

cd /home/$NB_USER/work

# Enables the ipywidgets
jupyter nbextension enable --py --sys-prefix widgetsnbextension

# Start the notebook as $NB_USER
exec su $NB_USER -c "env PATH=$PATH jupyter notebook $*"

exit

# Handle special flags if we're root
if [ $UID == 0 ] ; then
    # Change UID of NB_USER to NB_UID if it does not match
    if [ "$NB_UID" != $(id -u $NB_USER) ] ; then
        usermod -u $NB_UID $NB_USER
        chown -R $NB_UID $CONDA_DIR
    fi

    # Enable sudo if requested
    if [ ! -z "$GRANT_SUDO" ]; then
        echo "$NB_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook
    fi

    # Start the notebook server
    exec su $NB_USER -c "env PATH=$PATH jupyter notebook $*"
else
    # Otherwise just exec the notebook
    exec jupyter notebook $*
fi

