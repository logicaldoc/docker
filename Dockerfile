# LogicalDOC Document Management System ( https://www.logicaldoc.com )
FROM openjdk:18-jdk-slim-bullseye

MAINTAINER LogicalDOC <packagers@logicaldoc.com>

# set default variables for LogicalDOC install 
ENV LDOC_VERSION="8.9.1"
ENV LDOC_MEMORY="3000"
ENV LDOC_USERNO=""
ENV SSH_PASSWORD="changeme"
ENV SSH_USER="logicaldoc"
ENV DEBIAN_FRONTEND="noninteractive"
ENV DB_ENGINE="mysql"
ENV DB_HOST="logicaldoc-db"
ENV DB_PORT="3306"
ENV DB_NAME="logicaldoc"
ENV DB_INSTANCE=""
ENV DB_USER="ldoc"
ENV DB_PASSWORD="changeme"
ENV DB_MANUALURL="false"
ENV DB_URL=""


RUN mkdir /LogicalDOC
COPY logicaldoc.sh /LogicalDOC
COPY auto-install.j2 /LogicalDOC
COPY wait-for-it.sh /
COPY wait-for-postgres.sh /

# Install the Tesseract OCR
RUN apt update
RUN apt-get -y install tesseract-ocr tesseract-ocr-deu tesseract-ocr-fra tesseract-ocr-spa tesseract-ocr-ita

# prepare system for java installation (to be removed)
RUN apt-get update && \
  apt-get -y install software-properties-common

# Packages needed to install LogicalDOC Enterprise
RUN apt-get -y install \
    curl \    
    unzip \    
    imagemagick \
    ghostscript \
    python3-jinja2 \
    python3-pip \
    mariadb-client \
    postgresql-client \
    vim \
    nano \
    sed \
    zip \
    wget \
    openssl \
    ftp \
    clamav \
    libfreetype6 \
    libreoffice \
    apt-utils \
    dos2unix

# Install a SSH daemon
RUN apt-get -y install openssh-server sudo
RUN useradd -rm -d /home/${SSH_USER} -s /bin/bash -g root -G sudo -u 1000 ${SSH_USER} 
RUN echo "${SSH_USER}:${SSH_PASSWORD}" | chpasswd 
RUN service ssh start
EXPOSE 22

# Download and unzip LogicalDOC installer 
RUN curl -L https://s3.amazonaws.com/logicaldoc-dist/logicaldoc/installers/logicaldoc-installer-${LDOC_VERSION}.zip \
    -o /LogicalDOC/logicaldoc-installer-${LDOC_VERSION}.zip && \
    unzip /LogicalDOC/logicaldoc-installer-${LDOC_VERSION}.zip -d /LogicalDOC && \
    rm /LogicalDOC/logicaldoc-installer-${LDOC_VERSION}.zip

# Fix the security policies of ImageMagick
RUN sed -i 's/<\/policymap>/  <policy domain=\"coder\" rights=\"read|write\" pattern=\"PDF\" \/><\/policymap>/' /etc/ImageMagick-6/policy.xml

# Install j2cli for the transformation of the templates (Jinja2)
RUN pip3 install j2cli

# Volumes for persistent storage
VOLUME /LogicalDOC/conf
VOLUME /LogicalDOC/repository

EXPOSE 8080

CMD ["/LogicalDOC/logicaldoc.sh", "start"]
