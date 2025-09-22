# LogicalDOC Document Management System ( https://www.logicaldoc.com )
FROM eclipse-temurin:21-jdk-noble

MAINTAINER LogicalDOC <packagers@logicaldoc.com>

# set default variables for LogicalDOC install 
ENV LDOC_VERSION="9.2.1"
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


# Install the Tesseract OCR
RUN apt update && apt-get -y install tesseract-ocr tesseract-ocr-deu tesseract-ocr-fra tesseract-ocr-spa tesseract-ocr-ita

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
    zip \
    wget \
    openssl \
    ftp \
    clamav \
    libfreetype6 \
    libreoffice \
    apt-utils \
    dos2unix \
    software-properties-common \
    openssh-server \
    j2cli \ 
    sudo 

# Make sure that root uses the right Java
RUN rm -f /usr/bin/java && ln -s /opt/java/openjdk/bin/java /usr/bin/java && chmod a+rx /usr/bin/java

# Create the service user
RUN groupadd -g 2000 logicaldoc && useradd -rm -d /home/${SSH_USER} -s /bin/bash -g logicaldoc -G sudo -u 2000 ${SSH_USER}
RUN echo "${SSH_USER}:${SSH_PASSWORD}" | chpasswd

# Make service user able to do sudo without password
RUN echo "${SSH_USER} ALL=NOPASSWD: ALL" >> /etc/sudoers

RUN mkdir /LogicalDOC && mkdir /LogicalDOC/conf && mkdir /LogicalDOC/repository && mkdir /installer && mkdir /logs 

# Download and unzip LogicalDOC installer
RUN curl -L https://s3.amazonaws.com/logicaldoc-dist/logicaldoc/installers/logicaldoc-installer-${LDOC_VERSION}.zip \
    -o /installer/logicaldoc-installer-${LDOC_VERSION}.zip && \
    unzip /installer/logicaldoc-installer-${LDOC_VERSION}.zip -d /installer && \
    rm /installer/logicaldoc-installer-${LDOC_VERSION}.zip


COPY logicaldoc.sh /
COPY auto-install.j2 /installer
COPY wait-for-it.sh /installer
COPY wait-for-postgres.sh /installer

RUN chown -R ${SSH_USER} /LogicalDOC && chown -R ${SSH_USER} /installer && chown -R ${SSH_USER} /logs

# Install a SSH daemon
RUN service ssh start
EXPOSE 22

# Fix the security policies of ImageMagick
RUN sed -i 's/<\/policymap>/  <policy domain=\"coder\" rights=\"read|write\" pattern=\"PDF\" \/><\/policymap>/' /etc/ImageMagick-6/policy.xml

# Fix the startup script
RUN sed -i "s/-u logicaldoc/-u ${SSH_USER}/" /logicaldoc.sh
RUN sed -i "s/\/logicaldoc\/pswd/\/${SSH_USER}\/pswd/" /logicaldoc.sh

# Volumes for persistent storage
VOLUME /LogicalDOC
VOLUME /LogicalDOC/conf
VOLUME /LogicalDOC/repository

EXPOSE 8080

CMD ["/logicaldoc.sh", "start"]
