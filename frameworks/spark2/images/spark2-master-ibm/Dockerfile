FROM ubuntu:14.04

MAINTAINER Pace Francesco <francesco.pace@eurecom.fr>

# JAVA Installation
RUN apt-get update && apt-get install -y --force-yes software-properties-common python-software-properties
RUN apt-add-repository -y ppa:webupd8team/java
RUN /bin/echo debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get update && apt-get -y install oracle-java7-installer oracle-java7-set-default curl
ENV JAVA_HOME /usr/lib/jvm/java-7-oracle/

RUN apt-get update && apt-get install -y --force-yes --no-install-recommends \
    git \
    unzip \
    libxrender-dev \
    libxtst-dev \
    wget \
    build-essential \
    && apt-get clean

# MAVEN Installation
ENV MAVEN_VERSION 3.5.0
RUN apt-get purge -y maven
RUN wget "http://mirror.olnevhost.net/pub/apache/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz" -O - | tar -xz -C /usr/local/
RUN ln -s "/usr/local/apache-maven-${MAVEN_VERSION}/bin/mvn" /usr/bin/mvn

#IBM-SPARK Installation
ARG SPARK_VERSION
ENV SPARK_VERSION ${SPARK_VERSION:-2.1.0}
ARG HADOOP_VERSION
ENV HADOOP_VERSION ${HADOOP_VERSION:-2.6}
ENV MAVEN_OPTS "-Xmx2g -XX:MaxPermSize=512M -XX:ReservedCodeCacheSize=512m"

COPY files/pushdown/ /opt/pushdown/
WORKDIR /usr/local/src
RUN git clone https://github.com/apache/spark.git
WORKDIR /usr/local/src/spark
RUN git checkout tags/v$SPARK_VERSION
WORKDIR /usr/local/src/spark/sql/core/src
RUN git apply /opt/pushdown/patches/sparkFileFilters-17Apr24.patch
WORKDIR /usr/local/src/spark
RUN mvn -Phadoop-$HADOOP_VERSION -Dhadoop.version=$HADOOP_VERSION.0 -DskipTests package
WORKDIR /opt
RUN ln -s /user/local/src/spark spark
ENV SPARK_HOME /opt/spark
ENV PATH /opt/spark/bin:/opt/spark/sbin:${PATH}

# IBM-STOCATOR Installation
ENV STOCATOR_VERSION 1.0.9
WORKDIR /usr/local/src/
RUN git clone https://github.com/SparkTC/stocator.git
WORKDIR /usr/local/src/stocator
#RUN git checkout tags/v$STOCATOR_VERSION
RUN mvn install
RUN mvn clean package -Pall-in-one
RUN cp /usr/local/src/stocator/target/stocator-${STOCATOR_VERSION}-SNAPSHOT-jar-with-dependencies.jar /opt/spark/stocator-${STOCATOR_VERSION}.jar

COPY files/pushdown/ /opt/pushdown/
WORKDIR /usr/local/src
RUN git clone https://github.com/apache/spark.git
WORKDIR /usr/local/src/spark
RUN got checkout tags/v$SPARK_VERSION
WORKDIR /user/local/src/spark/sql/core/src
RUN git apply /opt/pushdown/patches/sparkFileFilters-17Apr24.patch
WORKDIR /user/local/src/spark
RUN mvn -Phadoop-$HADOOP_VERSION -Dhadoop.version=$HADOOP_VERSION.0 -DskipTests package
WORKDIR /opt
RUN ln -s /user/local/src/spark spark
ENV SPARK_HOME /opt/spark
ENV PATH /opt/spark/bin:/opt/spark/sbin:${PATH}

COPY files/* /opt/
RUN chmod +x /opt/*.sh
EXPOSE 8080 7077

ENV SPARK_MASTER_PORT 7077
ENV SPARK_MASTER_WEBUI_PORT 8080

CMD /opt/start-master.sh

