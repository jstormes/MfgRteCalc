create table us_plant_list
(
    id         int auto_increment
        primary key,
    plant_name varchar(45) collate utf8mb3_uca1400_ai_ci not null,
    address_id int                                       null,
    active     tinyint(1) default 1                      not null,
    constraint us_plant_list_us_address_id_fk
        foreign key (address_id) references us_address (id)
);