FROM centos:5

MAINTAINER Daniele Venzano <venza@brownhat.org>

RUN yum -y update && yum -y install openssh-clients wget unzip openssh-server

COPY files/openmpi-1.6.5-1.x86_64.rpm /opt

RUN yum -y install --nogpgcheck /opt/openmpi-1.6.5-1.x86_64.rpm

RUN /etc/init.d/sshd start

#RUN echo 'root:screencast' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#   StrictHostKeyChecking ask/   StrictHostKeyChecking no/' /etc/ssh/ssh_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

RUN mkdir -p /root/.ssh
RUN ssh-keygen -q -t rsa -N '' -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
COPY files/mpirun.sh /usr/local/bin

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]

