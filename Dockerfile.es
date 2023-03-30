# vim:set ft=dockerfile:
FROM --platform=${TARGETPLATFORM} centos:8

# Buildx-specific
ARG TARGETARCH

# Check that the token was set
ARG TOKEN
RUN test -n "${TOKEN}"

# Add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mysql && useradd -r -g mysql mysql

# CentOS 8
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-Linux-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-Linux-*

# Install MariaDB repo
COPY mariadb.repo /etc/yum.repos.d/
RUN sed -i "s/<TOKEN>/${TOKEN}/" /etc/yum.repos.d/mariadb.repo

# Install epel, update and install the rest
RUN yum -y install epel-release && \
    yum -y update && \
    yum -y install \
        bind-utils \
        ca-certificates \
        gnupg \
        less \
        tzdata \
        wget \
        google-authenticator \
        yum-utils \
        pam_ldap \
        socat \
        which \
        MariaDB-server \
        MariaDB-backup \
        MariaDB-cracklib-password-check && \
    yum clean all && \
    rm -rf /var/cache/yum

# Add gosu for easy step-down from root
ENV GOSU_VERSION=1.13
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${TARGETARCH}"
RUN chmod +x /usr/local/bin/gosu

# Server init directories
RUN mkdir /docker-entrypoint-initdb.d && mkdir /docker-entrypoint-startdb.d

RUN rm -rf /var/lib/mysql && \
    mkdir -p /var/lib/mysql /var/run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql /var/run/mysqld && \
    # Ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID our mysqld instance ends up having at runtime
    chmod 777 /var/run/mysqld && \
    # Create log directory and set correct user
    mkdir -p /var/log/mysql && \
    chown -R mysql:mysql /var/log/mysql


COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s /usr/local/bin/docker-entrypoint.sh / # backwards compat
RUN ln -s /usr/libexec/mysqld /usr/bin/mysqld
RUN mkdir -p /etc/mysql/mariadb.conf.d/
COPY my.cnf /etc/my.cnf
COPY mariadb /etc/pam.d/mariadb
COPY mariadb2fa /etc/pam.d/mariadb2fa

# initialize the DB and save it to an archive
RUN docker-entrypoint.sh mysqld && \
    mv /var/lib/mysql /var/lib/mysql_init

VOLUME /var/lib/mysql

ARG VERSION
ARG GIT_COMMIT
ARG GIT_TREE_STATE
ARG BUILD_TIME

RUN if [ ! -z ${VERSION} ] && [ ! -z ${GIT_COMMIT} ] && [ ! -z ${BUILD_TIME} ]; then \
    printf "Version:    ${VERSION}\nGit commit: ${GIT_COMMIT}${GIT_TREE_STATE}\nBuilt:      ${BUILD_TIME}\n" > /opt/image_details; fi

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306
CMD ["mysqld"]
