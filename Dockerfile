# LogicalDOC Document Management System ( https://www.logicaldoc.com )
FROM openjdk:11-jdk

MAINTAINER LogicalDOC <packagers@logicaldoc.com>

# set default variables for LogicalDOC install
ENV LDOC_VERSION="8.3.3"
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
COPY logicaldoc.sh /LogicalDOC
COPY auto-install.j2 /LogicalDOC
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
    mysql-client \
    postgresql-client \
    vim \
    nano \
    sed \
    zip \
    wget \
    openssl \
    xpdf \
    ftp \
    sendmail-bin \ 
    sendmail \
    clamav \
    zlib1g-dev \
    libjpeg-dev \
    libgif-dev  \
    libfreetype6-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libncurses5-dev \
    giflib-tools \
    libfreetype6 \
    gcc \
    build-essential \
    make \
    psmisc \
    libreoffice \
    tesseract-ocr

# Download and unzip LogicalDOC installer 
RUN curl -L https://s3.amazonaws.com/logicaldoc-dist/logicaldoc/installers/logicaldoc-installer-${LDOC_VERSION}.zip \
    -o /LogicalDOC/logicaldoc-installer-${LDOC_VERSION}.zip && \
    unzip /LogicalDOC/logicaldoc-installer-${LDOC_VERSION}.zip -d /LogicalDOC && \
    rm /LogicalDOC/logicaldoc-installer-${LDOC_VERSION}.zip

# Install j2cli for the transformation of the templates (Jinja2)
RUN pip install j2cli

# Volumes for persistent storage
VOLUME /LogicalDOC/conf
VOLUME /LogicalDOC/repository

EXPOSE 8080

CMD ["/LogicalDOC/logicaldoc.sh", "run"]
