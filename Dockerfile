# vim:set ft=dockerfile:

# Setup A Template Image
FROM centos:8

# Define ENV Variables
ARG TOKEN=${TOKEN}
ENV TINI_VERSION=v0.18.0
ENV MARIADB_VERSION=10.5

# Add MariaDB Enterprise Repo
ADD https://dlm.mariadb.com/enterprise-release-helpers/mariadb_es_repo_setup /tmp

RUN chmod +x /tmp/mariadb_es_repo_setup && \
    /tmp/mariadb_es_repo_setup --mariadb-server-version=${MARIADB_VERSION} --token=${TOKEN} --apply

# Update System
RUN dnf -y install epel-release && \
    dnf -y upgrade

# Install Various Packages/Tools
RUN dnf -y install bind-utils \
    bc \
    boost \
    expect \
    git \
    glibc-langpack-en \
    jemalloc \
    jq \
    less \
    libaio \
    monit \
    nano \
    net-tools \
    openssl \
    rsyslog \
    snappy \
    sudo \
    tcl \
    vim \
    wget

# Default Locale Variables
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

# Install MariaDB Packages
RUN dnf -y install \
     MariaDB-shared \
     MariaDB-client \
     MariaDB-server

# Add Tini Init Process
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini

# Create Persistent Volumes
VOLUME ["/etc/my.cnf.d","/var/lib/mysql"]

RUN mkdir -p /etc/my.cnf.d

# Copy Entrypoint To Image
COPY ./init/docker-entrypoint.sh /usr/bin/

# Do Some Housekeeping
RUN chmod +x /usr/bin/docker-entrypoint.sh && \
    ln -s /usr/bin/docker-entrypoint.sh /docker-entrypoint.sh && \
    sed -i 's|SysSock.Use="off"|SysSock.Use="on"|' /etc/rsyslog.conf && \
    sed -i 's|^.*module(load="imjournal"|#module(load="imjournal"|g' /etc/rsyslog.conf && \
    sed -i 's|^.*StateFile="imjournal.state")|#  StateFile="imjournal.state")|g' /etc/rsyslog.conf && \
    dnf clean all && \
    rm -rf /var/cache/dnf && \
    find /var/log -type f -exec cp /dev/null {} \; && \
    cat /dev/null > ~/.bash_history && \
    history -c

# Bootstrap
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["mariadbd --user=mysql"]
