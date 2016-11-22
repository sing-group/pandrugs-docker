FROM ubuntu:16.04
MAINTAINER dgpena@uvigo.es

ENV DEBIAN_FRONTEND noninteractive

# Only permanent packages
RUN apt-get update && apt-get install -y supervisor openjdk-8-jdk-headless mysql-server libdbi-perl libwww-perl libarchive-extract-perl libclone-perl

## CONFIGURATION OF TOMCAT+MYSQL FRAMEWORK #####
ENV APP_NAME pandrugsdb-backend
ENV APP_GIT_URL http://192.168.110.54/gitlab/pandrugsdb/pandrugsdb-backend.git
ENV DB_NAME pandrugsdb
ENV DB_USER pandrugsdb
ENV DB_PASS pandrugsdb
ENV DATA_DIR /${APP_NAME}_data
ENV MYSQL_CONNECTOR_J_URL http://central.maven.org/maven2/mysql/mysql-connector-java/5.1.21/mysql-connector-java-5.1.21.jar
ENV MAIL_API_URL http://central.maven.org/maven2/com/sun/mail/javax.mail/1.5.2/javax.mail-1.5.2.jar
ENV ACTIVATION_URL http://central.maven.org/maven2/javax/activation/activation/1.1.1/activation-1.1.1.jar
#################################################

## PANDRUGS APP CONFIGS ##
ENV PANDRUGS_FRONTEND_URL http://sing.citi.uvigo.es/static/pandrugs/pandrugsdb-frontend.zip
ENV PANDRUGS_ENSEMBL_85_TOOLS_URL http://sing.citi.uvigo.es/static/pandrugs/pandrugsdb-variantanalysis-data/ensembl-tools-release-85.zip
ENV VEP_PARSER_V15_URL http://sing.citi.uvigo.es/static/pandrugs/pandrugsdb-variantanalysis-data/vep-parser-v15.zip
ENV PANDRUGSDB_SQL_URL http://sing.citi.uvigo.es/static/pandrugs/pandrugsdb.sql.gz
##########################


# Supervisor
ADD start-mysqld.sh /start-mysqld.sh
ADD start-tomcat.sh /start-tomcat.sh
ADD run.sh /run.sh
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf
ADD supervisord-tomcat.conf /etc/supervisor/conf.d/supervisord-tomcat.conf

ADD mysql-setup.sh /mysql-setup.sh

# Tomcat
ENV TOMCAT_MAJOR 8
ENV TOMCAT_VERSION 8.0.39
ENV TOMCAT_TGZ_URL https://www.apache.org/dyn/closer.cgi?action=download&filename=tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

# Install base software
RUN apt-get install -y wget unzip \
	&& chmod 755 /*.sh \
	&& mkdir -p ${DATA_DIR}/database \
	&& sed /etc/mysql/mysql.conf.d/mysqld.cnf -i -e 's#/var/lib/mysql#'"${DATA_DIR}"'/database#g' \
	&& sed /etc/mysql/mysql.conf.d/mysqld.cnf -i -e 's/127\.0\.0\.1/0.0.0.0/g' \
	&& chmod 755 /*.sh \
	&& wget "$TOMCAT_TGZ_URL" -O /opt/tomcat.tar.gz \
	&& mkdir /opt/tomcat \
	&& tar xzvf /opt/tomcat.tar.gz --strip-components=1 -C /opt/tomcat \
	&& rm /opt/tomcat.tar.gz \
	&& wget $MYSQL_CONNECTOR_J_URL -O /opt/tomcat/lib/mysq-connector.jar && wget $MAIL_API_URL -O /opt/tomcat/lib/mail-api.jar && wget $ACTIVATION_URL -O /opt/tomcat/lib/activation.jar \
	&& apt-get remove --purge -y wget unzip && apt-get clean

# Variant analysis databases and vep-parser
RUN apt-get install -y wget unzip \
	&& mkdir /vep-parser && wget $VEP_PARSER_V15_URL -O vep-parser.zip \ 
	&& unzip vep-parser.zip -d /vep-parser \ 
	&& rm vep-parser.zip \
	&& sed /vep-parser/VEP_parser_v15.pl -i -e 's#use lib.*#use lib "/vep-parser/modules";#g' \
	&& apt-get remove --purge -y wget unzip && apt-get clean

RUN apt-get install -y wget unzip \
	&& wget $PANDRUGS_ENSEMBL_85_TOOLS_URL -O ensembl-85.zip \
	&& unzip ensembl-85.zip \
	&& rm ensembl-85.zip \
	&& apt-get remove --purge -y wget unzip && apt-get clean


# Build App
RUN apt-get install -y wget unzip git maven \
	&& git clone $APP_GIT_URL \
	&& cd $APP_NAME && git checkout develop && mvn -DskipTests=true package && mv target/${APP_NAME}.war /opt/tomcat/webapps \
	&& unzip /opt/tomcat/webapps/${APP_NAME}.war -d /opt/tomcat/webapps/${APP_NAME} && rm /opt/tomcat/webapps/${APP_NAME}.war \
	&& wget $PANDRUGS_FRONTEND_URL -O pandrugs-frontend.zip \
	&& unzip pandrugs-frontend.zip -d /opt/tomcat/webapps/pandrugs \
	&& rm pandrugs-frontend.zip \
	&& apt-get remove --purge -y wget unzip git maven && rm -rf /${APP_NAME} && rm -rf /.m2 && apt-get clean

ADD context.xml /opt/tomcat/webapps/${APP_NAME}/META-INF/context.xml
RUN sed /opt/tomcat/webapps/${APP_NAME}/META-INF/context.xml -i -e 's#/tmp#'"${DATA_DIR}"'#g'
# Add volumes 
VOLUME $DATA_DIR

EXPOSE 8080 3306

CMD ["/run.sh"]