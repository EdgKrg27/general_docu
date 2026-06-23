FROM docker.io/library/mysql:lts

ENV MYSQL_ROOT_PASSWORD=root090215
ENV MYSQL_DATABASE=personal_finance
ENV MYSQL_USER=edgar
ENV MYSQL_PASSWORD=090215

COPY init.sql /docker-entrypoint-initdb.d/