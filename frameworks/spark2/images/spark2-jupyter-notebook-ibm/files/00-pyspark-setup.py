# Configure the necessary Spark environment
import os

# make sure pyspark tells workers to use python3 not 2 if both are installed
os.environ['PYSPARK_PYTHON'] = '/opt/conda/bin/python'

if 'SPARK_MASTER' in os.environ:
	import pyspark
	conf = pyspark.SparkConf()

	# point to mesos master or zookeeper entry (e.g., zk://10.10.10.10:2181/mesos)
	conf.setMaster(os.environ["SPARK_MASTER"])
	# set other options as desired
	conf.set("spark.executor.memory", os.environ["SPARK_EXECUTOR_RAM"])

	# create the context
	sc = pyspark.SparkContext(conf=conf)
