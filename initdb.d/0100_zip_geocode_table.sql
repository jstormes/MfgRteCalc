create table zip_geocode
(
    zip       char(5)        primary key,
    lat       decimal(10, 8) not null,
    lng       decimal(11, 8) not null,
    zip_point point          not null
);

create trigger zip_geocode_insert_trigger
    before insert
    on zip_geocode
    for each row
        SET NEW.zip_point = POINT(NEW.lng,NEW.lat);

DELIMITER $$
CREATE FUNCTION zip_point(zip1 char(5))
    RETURNS POINT
    DETERMINISTIC
BEGIN
    DECLARE p POINT;
    SELECT zip_point into p from zip_geocode where zip=zip1;
    return p;
END$$
DELIMITER ;
