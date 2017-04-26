# LogicalDOC Document Management System ( http://www.logicaldoc.com )
FROM phusion/baseimage
MAINTAINER "Alessandro Gasparini" <devel@logicaldoc.com>

ENV LDOC_VERSION="7.6.4"
ENV LDOC_MEMORY="2000"
ENV LDOC_USERNO=" "
ENV SSH_PSWD="logicaldoc"
ENV DEBIAN_FRONTEND="noninteractive"
ENV CATALINA_HOME="/opt/logicaldoc/tomcat"
ENV JAVA_HOME="/usr/lib/jvm/java-8-oracle/"
ENV KILL_PROCESS_TIMEOUT=100
ENV KILL_ALL_PROCESSES_TIMEOUT=100
ENV DB_ENGINE="mysql"
ENV DB_NAME="logicaldoc"
ENV DB_INSTANCE=""
ENV DB_USER="ldoc"
ENV DB_PASSWORD="changeme"
ENV DB_DBHOST="mysql-ld"
ENV DB_PORT="3306"

# Some preparations
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y perl pwgen --no-install-recommends 

# Prepare system for java installation
RUN apt-get -y install software-properties-common python-software-properties

# Install oracle java
RUN \
  echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer

# Some required software for LogicalDOC plugins
RUN apt-get -y install \
    mysql-client \
    imagemagick \
    curl \
    unzip \
    sudo \
    tar \
    ghostscript \
    tesseract-ocr \
    pdftohtml \
    openssl

# Setup LibreOffice 5.3.x from libreoffice/ppa
# https://launchpad.net/~libreoffice/+archive/ubuntu/ppa
RUN \
  add-apt-repository -y ppa:libreoffice/libreoffice-5-3 && \
  apt-get update && \
  apt-get install -y libreoffice

# Download and unzip logicaldoc installer 
RUN mkdir /opt/logicaldoc
RUN curl -L https://s3.amazonaws.com/logicaldoc-dist/logicaldoc/installers/logicaldoc-installer-${LDOC_VERSION}.zip \
    -o /opt/logicaldoc/logicaldoc-installer-${LDOC_VERSION}.zip  && \
    unzip /opt/logicaldoc/logicaldoc-installer-${LDOC_VERSION}.zip -d /opt/logicaldoc && \
    rm /opt/logicaldoc/logicaldoc-installer-${LDOC_VERSION}.zip


# Add configuration scripts
ADD 01_logicaldoc.sh /etc/my_init.d/
ADD auto-install.j2 /opt/logicaldoc
RUN chmod +x /etc/my_init.d/*

RUN apt-get -y install python-jinja2 python-pip
RUN pip install j2cli

# logicaldoc service setup
RUN mkdir /etc/service/logicaldoc/
ADD logicaldoc.sh /etc/service/logicaldoc/run
RUN chmod +x /etc/service/logicaldoc/run

# logicaldoc update watch dog
RUN mkdir /etc/service/logicaldoc-update
ADD logicaldoc-update.sh /etc/service/logicaldoc-update/run
RUN chmod +x /etc/service/logicaldoc-update/run

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Enable SSH
RUN rm -f /etc/service/sshd/down

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Setup the logicaldoc password
RUN useradd logicaldoc && \
echo "logicaldoc:${SSH_PSWD}" | chpasswd && \
echo "logicaldoc  ALL=(ALL:ALL) ALL" >> /etc/sudoers

# Volumes for persistent storage
VOLUME /opt/logicaldoc/conf
VOLUME /opt/logicaldoc/repository

# Ports to connect to
EXPOSE 8080 22

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

