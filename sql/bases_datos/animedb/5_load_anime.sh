#!/bin/bash

set -e
echo "Cargando animes desde un csv"
export MYSQL_PWD='root090215'
mysql --local-infile=1 --user=root --database=animedb <<EOF
SET autocommit=0;
SET unique_checks=0;
SET foreign_key_checks=0;

LOAD DATA LOCAL INFILE '/docker-entrypoint-initdb.d/3_anime_genre.csv'
INTO TABLE anime_genre
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(anime_id, genre_id);

LOAD DATA LOCAL INFILE '/docker-entrypoint-initdb.d/4_anime.csv'
INTO TABLE anime
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(anime_id, name, type_id, episodes, rating, members);

COMMIT;
SET unique_checks=1;
SET foreign_key_checks=1;
EOF


echo "Carga de animes finalizada"