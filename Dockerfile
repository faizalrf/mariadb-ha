# vim:set ft=dockerfile:

# Pull the CentOS7 image
FROM centos:latest
USER root

# Update System
# RUN yum -y -q install epel-release && yum -y -q upgrade

ARG SERVER_VERSION
ARG ES_TOKEN
ARG PORT

COPY ./init/mariadb.repo /etc/yum.repos.d/

# Update System
RUN dnf -y install epel-release && \
    dnf -y update && \
    dnf -y upgrade

# Setup MariaDB repositories
RUN yum -y -q install wget
# RUN wget https://dlm.mariadb.com/enterprise-release-helpers/mariadb_es_repo_setup
# RUN chmod +x mariadb_es_repo_setup
# RUN ./mariadb_es_repo_setup --token="${ES_TOKEN}" --apply --mariadb-server-version="${SERVER_VERSION}"
# RUN echo "Token: ${ES_TOKEN}" && echo "Server Version: ${SERVER_VERSION}" && echo "Port: ${PORT}"

# Create Persistent Volumes
# VOLUME ["/etc/my.cnf.d","/var/lib/mysql"]

RUN yum -y -q install MariaDB-server

# Expose Mysql port 3306
EXPOSE ${PORT}

LABEL version="10.5"
LABEL description="MariaDB Server"

# Start the service
# CMD test -d /var/run/mariadb || mkdir -p /var/run/mariadb; chmod 0777 /var/lib/mysql; chmod 0777 /var/run/mariadb; /usr/sbin/mariadbd --basedir=/usr --datadir=/var/lib/mysql --user=mysql
CMD /usr/sbin/mariadbd --basedir=/usr --datadir=/var/lib/mysql --user=mysql
