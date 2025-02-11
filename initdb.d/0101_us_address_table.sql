# According to USPS, a standardized address spans three lines and covers the
# name of the receiver in the first line, street address in the second one,
# and the city, state, and zip code in the third line. Moreover, all letters
# are expected to be written in uppercase to ensure standardized format.

create table us_address
(
    id             int auto_increment
        primary key,
    address_line_1 nvarchar(40),
    address_line_2 nvarchar(40),
    city           nvarchar(45), # The longest city name in the United States is Chargoggagoggmanchauggagoggchaubunagungamaugg, a 45-letter lake in Webster, Massachusetts
    state          nvarchar(15),
    zip            char(5) null,
    zip_4          char(4) null,
    constraint us_address_zip_geocode_fk
        foreign key (zip) references zip_geocode (zip)
);
