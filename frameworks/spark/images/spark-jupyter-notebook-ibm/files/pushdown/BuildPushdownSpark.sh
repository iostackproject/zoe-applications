#!/bin/bash 

############################################################
#
#  Yosef Moatti 
#
#  Functionallity:
#  Build the Spark SQL pushdown from scratch
#  Following components have to be cloned, patched and built:
#  1. joss (Java written library to access swift, used by stocator)
#  2. stocator (this is the modern driver to access swift from spark
#  3. hadoop 
#  4. spark 
#  5. spark-csv
#
#  Usage: BuildPushdownSpark < --skipClone >
#
#  the --skipClone optional switch will cause the git repositories
#  not to be cloned. The used code is the code
#  that will be found in the various component trees
#
#  Assumptions:  
#
############################################################

E_BADARGS=65  # Exit error code
BASENAME=`basename $0`
BASEFOLDER=$(dirname $(readlink -f ${0}))
VERSION=0.23

### BUILD_DIR is the directory in which hadoop, spark, spark-csv, joss and stocator are built
BUILD_DIR="${BASEFOLDER}/build"
### PATCHES_DIR is the directory where all the patches were copied
PATCHES_DIR="${BASEFOLDER}/patches"
IVY2_BASE="${HOME}/.ivy2/cache"

############################################################
# Usage function                                           #
############################################################
# usage ()
# {
#     echo "Usage: " $BASENAME <--skipClone>
# }
############################################################
# Start of the script flow:

if [ $# -ge 1 ]
then
    if [[ $1 = "--skipClone" ]]
    then
	echo "The code trees will not be cloned and patched"
	SKIPCLONE="true"
	shift
    fi
fi

############################################################
# Test success of previous step                            #
############################################################
testSuccess ()
{
    LATEST=$?
    if [ ! "$LATEST" -eq "0" ]
    then
	echo "Value of latest return code is $LATEST"
	exit 1
    fi
}

############################################################
# Test success of previous step                            #
############################################################
runNextStep ()
{
    echo "Next step: $cmdLine ...starting at " `date | gawk '{print $4}'`
    eval ${cmdLine}
    testSuccess
    ### next command line helps to catch failures at building the next cmdLine
    cmdLine="echo \"WARNING: next command line failed to be built!\""
}

installPrereq ()
{
    sudo apt-get update && sudo apt-get install -y --force-yes software-properties-common python-software-properties
    sudo apt-add-repository -y ppa:webupd8team/java
    /bin/echo debconf shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
    sudo apt-get update && sudo apt-get -y install oracle-java7-installer oracle-java7-set-default curl
    export JAVA_HOME="/usr/lib/jvm/java-7-oracle/"

    sudo apt-get update && sudo apt-get install -y --force-yes --no-install-recommends \
        git \
        unzip \
        libxrender-dev \
        libxtst-dev \
        wget \
        build-essential \
        && sudo apt-get clean

    # MAVEN Installation
    MAVEN_VERSION="3.3.3"
    sudo apt-get purge -y maven
    wget "http://mirror.olnevhost.net/pub/apache/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz" -O - | sudo tar -xzf --no-same-owner -C /usr/local/
    sudo ln -s "/usr/local/apache-maven-${MAVEN_VERSION}/bin/mvn" /usr/bin/mvn

    # PROTOBUF 2.5.0 Installation
    sudo apt-get install -y dh-autoreconf
    wget https://github.com/google/protobuf/archive/v2.5.0.tar.gz -O - | sudo tar -xzf --no-same-owner -C /usr/local/src/
    pushd /usr/local/src/protobuf-2.5.0
    sudo ./autogen.sh && sudo ./configure --prefix=/usr && sudo make && sudo make install 
    pushd /usr/local/src/protobuf-2.5.0/java
    sudo mvn install && sudo mvn package
    popd
    popd
}

installJoss ()
{
    if [ -z "$SKIPCLONE" ]; then   
        JOSS_GIT_SITE=https://github.com/ymoatti/pushdown-joss            ####  https://github.com/javaswift/joss

        #### JOSS
        cd $BUILD_DIR
        cmdLine="git clone $JOSS_GIT_SITE"; runNextStep
        cd $JOSS_DIR_NAME
        cmdLine="git checkout tags/$JOSS_PREFIX$JOSS_VERSION"; runNextStep
		cmdLine="git checkout -b "my-"$JOSS_PREFIX$JOSS_VERSION"; runNextStep
    else
        echo "skiping the clone, checkout and patch steps "
    fi
    
    cd $BUILD_DIR/$JOSS_DIR_NAME
    cmdLine="time mvn install"; runNextStep
}

installStocator ()
{
    if [ -z "$SKIPCLONE" ]; then   
        STOCATOR_GIT_SITE=https://github.com/ymoatti/pushdown-stocator    ####  https://github.com/SparkTC/stocator.git
        
        #### STOCATOR
        cd $BUILD_DIR
        cmdLine="git clone $STOCATOR_GIT_SITE"; runNextStep
        cd $STOCATOR_DIR_NAME
        cmdLine="git checkout tags/$STOCATOR_PREFIX$STOCATOR_VERSION"; runNextStep
		cmdLine="git checkout -b "my-"$STOCATOR_PREFIX$STOCATOR_VERSION"; runNextStep
    else
        echo "skiping the clone, checkout and patch steps "
    fi
    
    cd $BUILD_DIR/$STOCATOR_DIR_NAME
    cmdLine="time mvn install"; runNextStep
}

compileSpark ()
{
    if [ -z "$SKIPCLONE" ]; then   
        HADOOP_GIT_SITE=git://git.apache.org/hadoop.git
        SPARK_GIT_SITE=git://git.apache.org/spark.git
        SPARK_CSV_GIT_SITE=https://github.com/databricks/spark-csv

        HADOOP_PATCH=hadoop-$HADOOP_VERSION-pushdown-$HADOOP_PATCH_NUMBER.patch
        SPARK_PATCH=spark-$SPARK_VERSION-pushdown-$SPARK_PATCH_NUMBER.patch
        SPARK_CSV_PATCH=spark-csv-$SPARK_CSV_VERSION-pushdown-$CSV_SPARK_PATCH_NUMBER.patch

        #### hadoop
        cd $BUILD_DIR
        cmdLine="git clone $HADOOP_GIT_SITE"; runNextStep
        cd $HADOOP_DIR_NAME
        cmdLine="git checkout tags/$HADOOP_PREFIX$HADOOP_VERSION"; runNextStep
        cmdLine="git checkout -b "my-"$HADOOP_PREFIX$HADOOP_VERSION"; runNextStep
        cmdLine="git apply $PATCHES_DIR/$HADOOP_PATCH"; runNextStep

        #### SPARK_CSV
        cd $BUILD_DIR
        cmdLine="git clone $SPARK_CSV_GIT_SITE"; runNextStep
        cd $SPARK_CSV_DIR_NAME
        cmdLine="git checkout tags/$SPARK_CSV_PREFIX$SPARK_CSV_VERSION"; runNextStep
        cmdLine="git checkout -b "my-"$SPARK_CSV_PREFIX$SPARK_CSV_VERSION"; runNextStep
        cmdLine="git apply $PATCHES_DIR/$SPARK_CSV_PATCH"; runNextStep

        #### SPARK
        cd $BUILD_DIR
        cmdLine="git clone $SPARK_GIT_SITE"; runNextStep
        cd $SPARK_DIR_NAME
        cmdLine="git checkout tags/$SPARK_PREFIX$SPARK_VERSION"; runNextStep
        cmdLine="git checkout -b "my-"$SPARK_PREFIX$SPARK_VERSION"; runNextStep
        cmdLine="git apply $PATCHES_DIR/$SPARK_PATCH"; runNextStep
        cd ..

        if [ -n "$IBM" ]; then   
            ### Fix Hadoop file which causes compilation errors for IBM JDK:
            echo "We now fix the TestSecureLogins.java for compiling with IBM JDK..."
            cd $BUILD_DIR/hadoop/hadoop-yarn-project/hadoop-yarn/hadoop-yarn-registry/src/test/java/org/apache/hadoop/registry/secure/;
            cat TestSecureLogins.java | sed 's/import com.sun.security.auth.module.Krb5LoginModule/import com.ibm.security.auth.module.Krb5LoginModule/' > xxyyzz
            testSuccess
            mv xxyyzz TestSecureLogins.java
        fi
    else
        echo "skiping the clone, checkout and patch steps "
    fi

    cd $BUILD_DIR/$HADOOP_DIR_NAME
    export MAVEN_OPTS="-Xmx2g -XX:MaxPermSize=512M -XX:ReservedCodeCacheSize=512m"
    cmdLine="time mvn -DskipTests install package"; runNextStep

    echo "BUILD_DIR is $BUILD_DIR"
    echo "SPARK_DIR_NAME is $SPARK_DIR_NAME"
    cd $BUILD_DIR
    cd $SPARK_DIR_NAME
    pwd
    export MAVEN_OPTS="-Xmx2g -XX:MaxPermSize=512M -XX:ReservedCodeCacheSize=512m"
    cmdLine="time mvn -Phadoop-$HADOOP_VERSION -Dhadoop.version=$HADOOP_VERSION -DskipTests package"; runNextStep

    cd $BUILD_DIR
    mkdir -p $IVY2_BASE/org.apache.spark/spark-core_2.10/jars
    cmdLine="cp $SPARK_DIR_NAME/core/target/spark-core_2.10-$SPARK_VERSION.jar $IVY2_BASE/org.apache.spark/spark-core_2.10/jars"; runNextStep

    mkdir -p $IVY2_BASE/org.apache.hadoop/hadoop-openstack/jars
    cmdLine="cp $HADOOP_DIR_NAME/hadoop-tools/hadoop-openstack/target/hadoop-openstack-$HADOOP_VERSION.jar $IVY2_BASE/org.apache.hadoop/hadoop-openstack/jars"; runNextStep

    mkdir -p $IVY2_BASE/org.apache.hadoop/hadoop-mapreduce-client-core/jars
    cmdLine="cp $HADOOP_DIR_NAME/hadoop-mapreduce-project/hadoop-mapreduce-client/hadoop-mapreduce-client-core/target/hadoop-mapreduce-client-core-$HADOOP_VERSION.jar $IVY2_BASE/org.apache.hadoop/hadoop-mapreduce-client-core/jars"; runNextStep

    echo "display the latest jars copied to in $IVY2_BASE"
    find $IVY2_BASE -name \*.jar -mmin -5 -exec ls -lt {} \;


    echo "Next step: build spark-csv based on modified SPARK...starting at " `date | gawk '{print $4}'`
    cd $BUILD_DIR/$SPARK_CSV_DIR_NAME
    cmdLine="cp -f ${BASEFOLDER}/sbt$SBT_SUFIX.zip ."; runNextStep
    rm -rf sbt 2> /dev/null
    unzip sbt$SBT_SUFIX.zip
    chmod +x sbt/bin/sbt
    cmdLine="sbt/bin/sbt ++2.10.4 publish-m2"; runNextStep

    echo "Next step: rebuild spark again using now good spark-csv...starting at " `date | gawk '{print $4}'`
    cd $BUILD_DIR/$SPARK_DIR_NAME
    cmdLine="time mvn -Phadoop-$HADOOP_VERSION -Dhadoop.version=$HADOOP_VERSION -DskipTests package"; runNextStep
}


echo "Pushdown build started with $BASENAME version $VERSION ...started at " `date`

HADOOP_VERSION=2.7.1   # with 2.6.0 the swift test from local spark VM fails
SPARK_VERSION=1.6.1
SPARK_CSV_VERSION=1.2.0
STOCATOR_VERSION=pushdown-v0.3
JOSS_VERSION=pushdown-v0.2

HADOOP_PATCH_NUMBER=0002
SPARK_PATCH_NUMBER=0004   # 0003 is the version with fixed HadoopRDD (no Broadcast)  0004 is the version which tries to compile Stocator within Spark (but fails on run...)
CSV_SPARK_PATCH_NUMBER=0007
#STOCATOR_PATCH_NUMBER=NewSeekStructure0005
#JOSS_PATCH_NUMBER=0001

SBT_SUFIX=-0.13.9

HADOOP_PREFIX=release-
SPARK_PREFIX=v
SPARK_CSV_PREFIX=v
STOCATOR_PREFIX=
JOSS_PREFIX=

JOSS_DIR_NAME=pushdown-joss
STOCATOR_DIR_NAME=pushdown-stocator
SPARK_DIR_NAME=spark
SPARK_CSV_DIR_NAME=spark-csv
HADOOP_DIR_NAME=hadoop

echo "Used JDK is "
java -version

IBM=$(java -version 2>&1 | sed -n '/Ibm/I p');
if [ -n "$IBM" ]; then   
    echo "This is an IBM JDK"
else
    echo "This is NOT an IBM JDK"
fi

if [ ! -d "${BUILD_DIR}" ]
then
    mkdir -p ${BUILD_DIR}
fi
cd ${BUILD_DIR}
testSuccess

if [ -z "$SKIPCLONE" ]; then   
    DATE=`date | sed 's/ /X/g' | sed 's/:/Y/g' | sed 's/[^0-9a-zA-Z-]*//g'  `

    mkdir -p $BUILD_DIR-$DATE
    rm -rf $BUILD_DIR
    ln -s $BUILD_DIR-$DATE $BUILD_DIR
fi

# PRE-REQUISITE module Installation
#installPrereq

# JOSS Installation
#installJoss

# STOCATOR Installation
#installStocator

# SPARK Compilation
compileSpark

echo "Completed at " `date`
