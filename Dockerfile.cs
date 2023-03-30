FROM mariadb:latest

RUN apt -y update
RUN apt -y install pigz

COPY startup.sh /startup.sh
RUN chmod 755 /startup.sh

USER mysql:mysql
CMD /startup.sh
