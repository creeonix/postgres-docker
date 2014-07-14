FROM phusion/baseimage

ENV HOME /root

RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

CMD ["/sbin/my_init"]

RUN apt-get update
RUN apt-get install -y wget curl

# Postgres goes first
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main\n" > /etc/apt/sources.list.d/pgdg.list
RUN apt-get update
RUN apt-get -y install postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3 pwgen

RUN /usr/sbin/locale-gen en_US.UTF-8
RUN /usr/sbin/update-locale LANG=en_US.UTF-8

RUN echo "host all  all    0.0.0.0/0  trust" >> /etc/postgresql/9.3/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

RUN /etc/init.d/postgresql start &&\
    chpst -u postgres:postgres psql --command "CREATE USER teamcity WITH SUPERUSER PASSWORD 'teamcity';" &&\
    chpst -u postgres:postgres psql --command "update pg_database set datistemplate=false where datname='template1';" &&\
    chpst -u postgres:postgres psql --command "drop database Template1;" &&\
    chpst -u postgres:postgres psql --command "create database template1 with owner=postgres encoding='UTF-8' lc_collate='en_US.utf8' lc_ctype='en_US.utf8' template template0;" &&\
    chpst -u postgres:postgres psql --command "update pg_database set datistemplate=true where datname='template1';"

EXPOSE 5432

ADD service /etc/service

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
