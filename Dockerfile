# LogicalDOC Document Management System ( https://www.logicaldoc.com )
FROM openjdk:11-jdk

MAINTAINER LogicalDOC <packagers@logicaldoc.com>

# set default variables for LogicalDOC install
ENV LDOC_VERSION="8.4.2"
ENV LDOC_MEMORY="3000"
ENV LDOC_USERNO=""
ENV DEBIAN_FRONTEND="noninteractive"
ENV DB_ENGINE="mysql"
ENV DB_HOST="mysql-ld"
ENV DB_PORT="3306"
ENV DB_NAME="logicaldoc"
ENV DB_INSTANCE=""
ENV DB_USER="ldoc"
ENV DB_PASSWORD="changeme"
ENV DB_MANUALURL="false"
ENV DB_URL=""


RUN mkdir /LogicalDOC
COPY logicaldoc.sh /
COPY auto-install.j2 /
COPY wait-for-it.sh /
COPY wait-for-postgres.sh /

# prepare system for java installation (to be removed)
RUN apt-get update && \
  apt-get -y install software-properties-common

# Packages needed to install LogicalDOC Enterprise
RUN apt-get -y install \
    curl \    
    unzip \    
    imagemagick \
    ghostscript \
    python-jinja2 \
    python-pip \
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
    libreoffice

#Install Tesseract 4.1 for Debian 10 (Buster).
RUN echo "deb https://notesalexp.org/tesseract-ocr/buster/ buster main" >> /etc/apt/sources.list

RUN apt-get -y install apt-transport-https
RUN apt-get update -oAcquire::AllowInsecureRepositories=true
RUN apt-get -y --allow-unauthenticated install notesalexp-keyring -oAcquire::AllowInsecureRepositories=true
RUN apt-get update && \
    apt-get -y install tesseract-ocr tesseract-ocr-deu tesseract-ocr-fra tesseract-ocr-spa tesseract-ocr-ita


# Download and unzip LogicalDOC installer 
RUN curl -L https://s3.amazonaws.com/logicaldoc-dist/logicaldoc/installers/logicaldoc-installer-${LDOC_VERSION}.zip \
    -o /logicaldoc-installer-${LDOC_VERSION}.zip && \
    unzip /logicaldoc-installer-${LDOC_VERSION}.zip -d / && \
    rm /logicaldoc-installer-${LDOC_VERSION}.zip

# Install j2cli for the transformation of the templates (Jinja2)
RUN pip install j2cli

# Volumes for persistent storage
VOLUME /LogicalDOC
VOLUME /LogicalDOC/conf
VOLUME /LogicalDOC/repository

EXPOSE 8080

CMD ["/logicaldoc.sh", "run"]

