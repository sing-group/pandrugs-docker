FROM ubuntu:16.04
LABEL org.opencontainers.image.authors="dgpena@uvigo.es"

ENV DEBIAN_FRONTEND noninteractive

# Only permanent packages
RUN apt-get update && apt-get install -y supervisor openjdk-8-jdk-headless mysql-server libdbi-perl libwww-perl libarchive-extract-perl libclone-perl

## CONFIGURATION OF TOMCAT+MYSQL FRAMEWORK #####
ENV APP_NAME pandrugs-backend
ENV APP_BACKEND_VERSION 1.1.8
ENV APP_FRONTEND_VERSION 1.2.3
ENV APP_DATABASE_VERSION 20180328
ENV APP_DB_SCHEMA_VERSION 20221119
ENV APP_DB_DATA_VERSION 20210915
ENV DB_NAME pandrugsdb
ENV DB_USER pandrugsdb
ENV DB_PASS pandrugsdb
ENV DATA_DIR /${APP_NAME}_data
ENV MYSQL_CONNECTOR_J_URL https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.21/mysql-connector-java-5.1.21.jar
ENV MAIL_API_URL https://repo1.maven.org/maven2/com/sun/mail/javax.mail/1.5.2/javax.mail-1.5.2.jar
ENV ACTIVATION_URL https://repo1.maven.org/maven2/javax/activation/activation/1.1.1/activation-1.1.1.jar
ENV TOMCAT_AJAX_VALVE https://maven.sing-group.org/repository/maven-releases/org/sing_group/tomcat-ajax-authenticate/1.1/tomcat-ajax-authenticate-1.1.jar
#################################################

## PANDRUGS APP CONFIGS ##
ENV PANDRUGS_BACKEND_URL https://static.sing-group.org/pandrugs/pandrugs-backend-${APP_BACKEND_VERSION}.war
ENV PANDRUGS_FRONTEND_URL https://static.sing-group.org/pandrugs/pandrugs-frontend-${APP_FRONTEND_VERSION}.tar.gz
ENV PANDRUGS_VEP_URL https://static.sing-group.org/pandrugs/pandrugsdb-variantanalysis-data/vep90.zip
ENV VEP_PARSER_URL https://static.sing-group.org/pandrugs/pandrugsdb-variantanalysis-data/vep-parser-v19.zip
ENV VEP_PARSER_MAIN_SCRIPT VEP_parser_v19_PD.pl
ENV PANDRUGSDB_SCHEMA_SQL_URL https://static.sing-group.org/pandrugs/pandrugsdb-schema-${APP_DB_SCHEMA_VERSION}.sql.gz
ENV PANDRUGSDB_DATA_SQL_URL https://static.sing-group.org/pandrugs/pandrugsdb-noschema-${APP_DB_DATA_VERSION}.sql.gz
##########################

# Tomcat
ENV TOMCAT_MAJOR 8
ENV TOMCAT_VERSION 8.0.53
ENV TOMCAT_TGZ_URL https://www.apache.org/dyn/closer.cgi?action=download&filename=tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz

# Variant analysis databases and vep-parser
RUN apt-get update && apt-get install -y wget unzip \
	&& mkdir /vep-parser && wget $VEP_PARSER_URL -O vep-parser.zip \
	&& unzip vep-parser.zip -d /vep-parser \
	&& rm vep-parser.zip \
	&& sed /vep-parser/$VEP_PARSER_MAIN_SCRIPT -i -e 's#use lib.*#use lib "/vep-parser/modules";#g' \
	&& apt-get remove --purge -y wget unzip && apt-get clean

RUN apt-get update && apt-get install -y wget unzip \
	&& wget $PANDRUGS_VEP_URL -O vep.zip \
	&& unzip vep.zip -d /vep \
	&& sed /vep/.vep/Plugins/config/Condel/config/condel_SP.conf -i -e "s#condel\.dir.*#condel.dir='/vep/.vep/Plugins/config/Condel/'#g" \
	&& rm vep.zip \
	&& apt-get remove --purge -y wget unzip && apt-get clean

# Supervisor
ADD start-mysqld.sh /start-mysqld.sh
ADD start-tomcat.sh /start-tomcat.sh
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf
ADD supervisord-tomcat.conf /etc/supervisor/conf.d/supervisord-tomcat.conf

ADD mysql-setup.sh /mysql-setup.sh

# Install base software
RUN apt-get update && apt-get install -y wget unzip \
	&& chmod 755 /*.sh \
	&& mkdir -p ${DATA_DIR}/database \
	&& sed /etc/mysql/mysql.conf.d/mysqld.cnf -i -e 's#/var/lib/mysql#'"${DATA_DIR}"'/database#g' \
	&& sed /etc/mysql/mysql.conf.d/mysqld.cnf -i -e 's/127\.0\.0\.1/0.0.0.0/g' \
	&& chmod 755 /*.sh \
	&& wget "$TOMCAT_TGZ_URL" -O /opt/tomcat.tar.gz \
	&& mkdir /opt/tomcat \
	&& tar xzvf /opt/tomcat.tar.gz --strip-components=1 -C /opt/tomcat \
	&& rm /opt/tomcat.tar.gz \
	&& wget $MYSQL_CONNECTOR_J_URL -O /opt/tomcat/lib/mysql-connector.jar && wget $MAIL_API_URL -O /opt/tomcat/lib/mail-api.jar && wget $ACTIVATION_URL -O /opt/tomcat/lib/activation.jar \
	&& wget $TOMCAT_AJAX_VALVE -O /opt/tomcat/lib/tomcat-ajax-authenticate.jar \
	&& apt-get remove --purge -y wget unzip && apt-get clean

# Install app
RUN apt-get update && apt-get install -y wget unzip \
	&& wget $PANDRUGS_BACKEND_URL -O /opt/tomcat/webapps/${APP_NAME}.war \
	&& wget $PANDRUGS_FRONTEND_URL -O pandrugs-frontend.tar.gz \
	&& mkdir /opt/tomcat/webapps/pandrugs \
	&& tar -xzf pandrugs-frontend.tar.gz --directory /opt/tomcat/webapps/pandrugs \
	&& unzip /opt/tomcat/webapps/${APP_NAME}.war -d /opt/tomcat/webapps/${APP_NAME} \
	&& mv /opt/tomcat/webapps/ROOT /opt/tomcat/webapps/ROOT.bak && ln -s /opt/tomcat/webapps/pandrugs /opt/tomcat/webapps/ROOT \
	&& rm pandrugs-frontend.tar.gz \
	&& rm /opt/tomcat/webapps/${APP_NAME}.war \
	&& apt-get remove --purge -y wget unzip && apt-get clean

ADD context.xml /opt/tomcat/webapps/${APP_NAME}/META-INF/context.xml
RUN sed /opt/tomcat/webapps/${APP_NAME}/META-INF/context.xml -i -e 's#/tmp#'"${DATA_DIR}"'#g'

# Run script
ADD run.sh /run.sh

# Add volumes 
VOLUME $DATA_DIR

EXPOSE 8080 3306

CMD ["/run.sh"]
