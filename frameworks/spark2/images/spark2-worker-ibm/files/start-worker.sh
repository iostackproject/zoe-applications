#!/usr/bin/env bash


cat /opt/spark-defaults.conf | sed -e "s/XXX_DRIVER_MEMORY/$SPARK_DRIVER_RAM/" > ${SPARK_HOME}/conf/spark-defaults.conf

cd /opt/spark

./bin/spark-class org.apache.spark.deploy.worker.Worker \
	spark://${SPARK_MASTER_IP}:7077 --cores ${SPARK_WORKER_CORES:-4} --memory ${SPARK_WORKER_RAM:-4g} \
	-h ${SPARK_LOCAL_IP:-127.0.0.1} "$@"
