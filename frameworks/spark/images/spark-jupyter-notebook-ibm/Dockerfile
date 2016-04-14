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
RUN ln -s pushdown/build/spark-csv spark-csv
ENV SPARK_HOME /opt/spark
ENV PATH /opt/spark/bin:/opt/spark/sbin:${PATH}


RUN apt-get update && apt-get install -y --force-yes --no-install-recommends \
    vim \
    python-dev \
    ca-certificates \
    bzip2 \
    libsm6 \
    pandoc \
    texlive-latex-base \
    texlive-latex-extra \
    texlive-fonts-extra \
    texlive-fonts-recommended \
    texlive-generic-recommended \
    sudo \
    locales \
    libxrender1 \
    && apt-get clean

    
RUN locale-gen en_US.UTF-8

# TINI Installation
RUN wget --quiet https://github.com/krallin/tini/releases/download/v0.6.0/tini && \
    echo "d5ed732199c36a1189320e6c4859f0169e950692f451c03e7854243b95f4234b *tini" | sha256sum -c - && \
    mv tini /usr/local/bin/tini && \
    chmod +x /usr/local/bin/tini

# Configure environment
ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH
#ENV HADOOP_HOME /opt/hadoop
#ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop
#ENV PATH $HADOOP_HOME/bin:$PATH
ENV SHELL /bin/bash
ENV NB_USER nbuser
ENV NB_UID 1000
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.9-src.zip
#ENV HADOOP_VERSION 2.7.1

# Create nbuser user with UID=1000 and in the 'users' group
RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && mkdir -p /opt/conda && chown $NB_USER /opt/conda

USER nbuser

# Setup nbuser home directory
RUN mkdir /home/$NB_USER/work && \
    mkdir /home/$NB_USER/.jupyter && \
    mkdir /home/$NB_USER/.local

# Install conda as nbuser
RUN cd /tmp && \
    mkdir -p $CONDA_DIR && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-3.9.1-Linux-x86_64.sh && \
    echo "6c6b44acdd0bc4229377ee10d52c8ac6160c336d9cdd669db7371aa9344e1ac3 *Miniconda3-3.9.1-Linux-x86_64.sh" | sha256sum -c - && \
    /bin/bash Miniconda3-3.9.1-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-3.9.1-Linux-x86_64.sh && \
    $CONDA_DIR/bin/conda install --yes conda==3.14.1

# Install Jupyter notebook as nbuser
RUN conda install --yes \
    'notebook=4.0*' \
    terminado \
    && conda clean -yt

# Install Python 3 packages
RUN conda install --yes \
    'ipywidgets=4.0*' \
    'pandas=0.17*' \
    'matplotlib=1.4*' \
    'scipy=0.16*' \
    'seaborn=0.6*' \
    'scikit-learn=0.16*' \
    && conda clean -yt
RUN $CONDA_DIR/bin/pip install plotly gmaps
USER root

#RUN curl -s http://apache.mirrors.ovh.net/ftp.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar -xz -C /opt/
#RUN ln -s /opt/hadoop-${HADOOP_VERSION} /opt/hadoop

# Add Spark JARs
#RUN curl http://central.maven.org/maven2/com/databricks/spark-csv_2.10/1.3.0/spark-csv_2.10-1.3.0.jar -o /opt/spark/com.databricks_spark-csv_2.10-1.3.0.jar
RUN curl http://central.maven.org/maven2/org/apache/commons/commons-csv/1.2/commons-csv-1.2.jar -o /opt/spark/org.apache.commons_commons-csv-1.2.jar
RUN curl http://central.maven.org/maven2/com/univocity/univocity-parsers/1.5.6/univocity-parsers-1.5.6.jar -o /opt/spark/com.univocity_univocity-parsers-1.5.6.jar

COPY files/spark-defaults.conf /opt/spark-defaults.conf

# Configure container startup as root
EXPOSE 4040 8888 
WORKDIR /home/$NB_USER/work
ENTRYPOINT ["tini", "--"]
CMD ["start-notebook.sh"]

# Add local files as late as possible to avoid cache busting
COPY files/start-notebook.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/start-notebook.sh
COPY files/jupyter_notebook_config.py /home/$NB_USER/.jupyter/
RUN chown -R $NB_USER:users /home/$NB_USER/.jupyter
RUN mkdir -p /home/$NB_USER/.ipython/profile_default/startup/
COPY files/00-pyspark-setup.py /home/$NB_USER/.ipython/profile_default/startup/
RUN chown -R $NB_USER:users /home/$NB_USER/.ipython

COPY files/core-site.xml /opt
COPY files/hdfs-site.xml /opt

