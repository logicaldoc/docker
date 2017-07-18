# LogicalDOC Document Management System ( http://www.logicaldoc.com )
FROM centos:7 

ENV LDOC_VERSION="7.7.1"
ENV LIBREOFFICE_VERSION="5.3.4"
ENV LDOC_MEMORY="2000"
ENV LDOC_USERNO=" "
ENV LDOC_HOME="/LogicalDOC"
ENV JAVA_HOME="/usr/lib/jvm/jre"
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
RUN yum -y install epel-release
RUN rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

RUN yum upgrade -y && \
    yum install -y sed zip unzip wget openssl xpdf ftp sendmail clamav clamav-update && \
    yum install -y ghostscript ImageMagick zlib-devel libjpeg-devel giflib-devel && \
    yum install -y freetype-devel libjpeg-devel libpng-devel libtiff-devel zlib libjpeg && \
    yum install -y giflib freetype libjpeg libpng libtiff gcc gcc-c++ make python-pip && \
    yum install -y psmisc java-1.8.0-openjdk

RUN pip install j2cli

# Setup LibreOffice
RUN mkdir tmpx && cd tmpx && \
    wget "http://download.documentfoundation.org/libreoffice/stable/${LIBREOFFICE_VERSION}/rpm/x86_64/LibreOffice_${LIBREOFFICE_VERSION}_Linux_x86-64_rpm.tar.gz" && \
    tar zxvf LibreOffice_${LIBREOFFICE_VERSION}_Linux_x86-64_rpm.tar.gz && \
    cd LibreOffice_${LIBREOFFICE_VERSION}*/RPMS/ && \
    yum localinstall -y *.rpm && \
    cd ../../.. && rm -rf tmpx

# Install a recent version of  pdftohtml
RUN mkdir tmpx && cd tmpx && \
    wget ftp://ftp.foolabs.com/pub/xpdf/xpdfbin-linux-3.04.tar.gz && \
    tar xvzf xpdfbin-linux-3.04.tar.gz && \
    cp xpdfbin-linux-3.04/bin64/pdftohtml /usr/bin/ && \
    cd .. && rm -rf tmpx

# Install Tesseract OCR  
RUN mkdir tmpx && cd tmpx && \
    wget http://www.logicaldoc.net/files/leptonica-1.69.tar.gz && \
    tar xvf leptonica-1.69.tar.gz && \
    cd leptonica-1.69 && ./configure && make && make install && /sbin/ldconfig && \
    cd ../.. && rm -rf tmpx && mkdir tmpx && cd tmpx && \
    wget -c http://www.logicaldoc.net/files/tesseract-ocr-3.02.02.tar.gz && \
    tar -xvf tesseract-ocr-3.02.02.tar.gz && \
    cd tesseract-ocr && ./configure && make && make install && /sbin/ldconfig && \
    wget http://www.logicaldoc.net/files/tesseract-ocr-3.02.eng.tar.gz && \
    tar -xvzf tesseract-ocr-3.02.eng.tar.gz && \
    wget http://www.logicaldoc.net/files/tesseract-ocr-3.02.deu.tar.gz && \
    tar -xvzf tesseract-ocr-3.02.deu.tar.gz && \
    wget http://www.logicaldoc.net/files/tesseract-ocr-3.02.ita.tar.gz && \
    tar -xvzf tesseract-ocr-3.02.ita.tar.gz && \
    wget http://www.logicaldoc.net/files/tesseract-ocr-3.02.spa.tar.gz && \
    tar -xvzf tesseract-ocr-3.02.spa.tar.gz && \
    wget http://www.logicaldoc.net/files/tesseract-ocr-3.02.fra.tar.gz && \
    tar -xvzf tesseract-ocr-3.02.fra.tar.gz && \
    cp -Rf tesseract-ocr/tessdata /usr/local/share && cd ../.. && rm -rf tmpx

# Download and unzip logicaldoc installer 
RUN mkdir $LDOC_HOME
RUN curl -L https://s3.amazonaws.com/logicaldoc-dist/logicaldoc/installers/logicaldoc-installer-${LDOC_VERSION}.zip -o $LDOC_HOME/logicaldoc-installer-${LDOC_VERSION}.zip  && \
    unzip $LDOC_HOME/logicaldoc-installer-${LDOC_VERSION}.zip -d $LDOC_HOME && \
    rm $LDOC_HOME/logicaldoc-installer-${LDOC_VERSION}.zip 

# Volumes for persistent storage
VOLUME $LDOC_HOME/conf
VOLUME $LDOC_HOME/repository

# Ports to connect to
EXPOSE 8080

# Add the entry point script
COPY docker-entrypoint.sh /
RUN chmod +x docker-entrypoint.sh

# Add installation files
ADD auto-install.j2 $LDOC_HOME


ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/docker-entrypoint.sh"]
