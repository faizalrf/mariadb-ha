# vim:set ft=dockerfile:

# Pull the CentOS 8 image
FROM centos:8
USER root

# Update System
# RUN yum -y -q install epel-release && yum -y -q upgrade

ARG SERVER_VERSION
ARG ES_TOKEN
ARG PORT

# Community Setup
COPY ./init/mariadb.repo /etc/yum.repos.d/

# Update System
RUN yum -y install epel-release && \
    yum -y update && \
    yum -y upgrade

# Setup MariaDB repositories
#RUN yum -y -q install wget
#RUN wget https://downloads.mariadb.com/mariadb/mariadb_repo_setup
#RUN wget https://dlm.mariadb.com/enterprise-release-helpers/mariadb_es_repo_setup
#RUN chmod +x mariadb_repo_setup
#RUN ./mariadb_es_repo_setup
# RUN echo "Token: ${ES_TOKEN}" && echo "Server Version: ${SERVER_VERSION}" && echo "Port: ${PORT}"

# Create Persistent Volumes
VOLUME ["/etc/my.cnf.d","/var/lib/mysql"]

RUN yum -y -q install MariaDB-server

# Expose Mysql port 3306
EXPOSE ${PORT}

LABEL version="10.6"
LABEL description="MariaDB Server"

# Start the service
#CMD test -d /var/run/mariadb || mkdir -p /var/run/mariadb; chmod 0777 /var/lib/mysql; chmod 0777 /var/run/mariadb; /usr/sbin/mariadbd --basedir=/usr --datadir=/var/lib/mysql --user=mysql
CMD /usr/sbin/mariadbd --basedir=/usr --datadir=/var/lib/mysql --user=mysql
