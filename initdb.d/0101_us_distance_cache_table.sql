create table us_distance_cache
(
    zip1 char(5) not null,
    zip2   char(5) not null,
    distance float   not null,
    PRIMARY KEY (zip1, zip2),
    constraint us_distance_cache_zip_geocode_fk
        foreign key (zip1) references zip_geocode (zip),
    constraint us_distance_cache_zip_geocode_fk_2
        foreign key (zip2) references zip_geocode (zip)
);

DELIMITER $$
CREATE FUNCTION zip_distance($zip1 char(5), $zip2 char(5))
    RETURNS FLOAT
    DETERMINISTIC
BEGIN
    DECLARE count_of_zips_found INT DEFAULT 0;
    IF ($zip1=$zip2) THEN
        RETURN 0.0;
    END IF;
    IF $zip1<$zip2 THEN   # Put the smallest zip first, the distance to and from should be the same.
        SET @zip1=$zip1;  # Will cut our storage and memory caching requirements in half.
        SET @zip2=$zip2;
    ELSE
        SET @zip1=$zip2;
        SET @zip2=$zip1;
    END IF;
    SELECT COUNT(*) INTO count_of_zips_found FROM us_distance_cache WHERE zip1 = @zip1 AND zip2 = @zip2;
    IF count_of_zips_found=0 THEN
        SET @zip1_point:= (select zip_point from zip_geocode where zip = @zip1);
        SET @zip2_point:= (select zip_point from zip_geocode where zip = @zip2);
        SET @distance_calculated = ST_Distance_Sphere(@zip1_point, @zip2_point) * .000621371192;  # Distance in approx miles as the crow flies.
        insert into us_distance_cache (zip1, zip2, distance) values (@zip1, @zip2, @distance_calculated);
    END IF;
    select distance into @dist from us_distance_cache where zip1 = @zip1 and zip2 = @zip2;
    return @dist;
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION address_distance($from_address_id int, $to_address_id int)
    RETURNS FLOAT
    DETERMINISTIC
BEGIN
    SET @from_zip = (select zip from us_address where id=$from_address_id);
    SET @to_zip = (select zip from us_address where id=$to_address_id);
    RETURN zip_distance(@from_zip, @to_zip);
END$$
DELIMITER ;

