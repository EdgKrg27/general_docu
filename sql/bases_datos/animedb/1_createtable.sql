use animedb;

create table if not exists anime_type(
    type_id int auto_increment primary key,
    type_name varchar(50) unique
);

create table if not exists anime(
    anime_id int primary key,
    name varchar(255) not null,
    type_id int,
    episodes int,
    rating float,
    members int,
    foreign Key (type_id) references anime_type(type_id)
);

create table if not exists genre (
    genre_id int auto_increment primary key,
    genre_name varchar(100) unique
);

create table if not exists anime_genre (
    anime_id int,
    genre_id int,
    primary key (anime_id, genre_id),
    foreign key (anime_id) references anime(anime_id),
    foreign key (genre_id) references genre(genre_id)
);