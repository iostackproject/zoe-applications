# This dockerfile is generated, do not edit

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
ENV MAVEN_VERSION 3.3.3
RUN apt-get purge -y maven
RUN wget "http://mirror.olnevhost.net/pub/apache/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz" -O - | tar -xz -C /usr/local/
RUN ln -s "/usr/local/apache-maven-${MAVEN_VERSION}/bin/mvn" /usr/bin/mvn

# PROTOBUF 2.5.0 Installation
RUN apt-get install -y dh-autoreconf
RUN wget https://github.com/google/protobuf/archive/v2.5.0.tar.gz -O - | tar -xz -C /usr/local/src/
WORKDIR /usr/local/src/protobuf-2.5.0
RUN ./autogen.sh && ./configure --prefix=/usr && make -j && make -j install 
WORKDIR /usr/local/src/protobuf-2.5.0/java
RUN mvn install && mvn package

# IBM-JOSS Installation
WORKDIR /usr/local/src/
RUN git clone https://github.com/ymoatti/pushdown-joss
WORKDIR /usr/local/src/pushdown-joss
RUN git checkout tags/pushdown-v0.2
RUN git checkout -b my-pushdown-v0.2
RUN mvn install

# IBM-STOCATOR Installation
WORKDIR /usr/local/src/
RUN git clone https://github.com/ymoatti/pushdown-stocator
WORKDIR /usr/local/src/pushdown-stocator
RUN git checkout tags/pushdown-v0.3
RUN git checkout -b my-pushdown-v0.3
RUN mvn install
RUN ln -s /usr/local/src/pushdown-stocator /opt/stocator

# IBM-SPARK Installation
RUN apt-get update && apt-get install -y --force-yes --no-install-recommends gawk && apt-get clean
COPY files/pushdown/ /opt/pushdown/
RUN /bin/bash /opt/pushdown/BuildPushdownSpark.sh
WORKDIR /opt
RUN ln -s pushdown/build/spark spark
ENV SPARK_HOME /opt/spark
ENV PATH /opt/spark/bin:/opt/spark/sbin:${PATH}


COPY files/* /opt/
RUN chmod +x /opt/*.sh
RUN apt-get update && apt-get -y install python3 python3-numpy

ENV NB_USER nbuser
ENV NB_UID 1000

# Create nbuser user with UID=1000 and in the 'users' group
RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER

EXPOSE 8888 8081

CMD /opt/start-worker.sh

#ENV SPARK_WORKER_PORT 8888
#ENV SPARK_WORKER_WEBUI_PORT 8081