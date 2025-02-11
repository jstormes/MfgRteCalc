# Manufacturing Routing Calculator

As a business owner I want to know the best manufacturing facility to select
when a new order arrives.

The criteria for selecting the best facility are in order of descending 
priority:

* Closest location to the customers shipping address.  The business 
lives or dies on the margins.  One of the biggest margin prices is shipping
so by selecting the shortest shipping distance, we should overall get the
best shipping price.
* Closest location with the capability to manufacture the requested item.
It does no good to know the closest facility if we cannot make the requested
product at that facility.  The limitations to consider are:
  * Function - does the facility have the proper machines to make the 
               requested item(s).
  * Material - does the facility have the proper inventory to make the
               requested item(s).
  * Workload - does the facility have the proper amount of personal and 
               machines with enough duty to do the job timely.
  * Staffing - does the facility have the properly trained staff to create 
               the item.  
  * Operating Cost - does the facility cost more or less than the possible
                     alternatives.

## Unspoken Goals

As an older coder I have written this solution a few times during my career.
In this proof of concept I want to take this problem and solve it in a new 
way.  I want to make the database "true" at all times.  I don't want any 
background scheduled tasks or "sweeps" that "clean up" the data as we cannot
seem to do it real time.  

This will mean paying very close attention to the Big "O" of all the code.
It will also mean pushing the operations to the tier that make the most 
sense, that is true n-tier development.  The database, the API and the 
front end will all have to do what they do best, and only what they do best.

The goal is to write as little code as possible with best practice in testing
and error trapping.  Error logging should only happen on "true" error that
need attention by the operations staff.

## Scope limits

This proof of concept will be limited to business inside the US.  While it 
would be possible to do a global version.  For now in the interest of time
I will only be approaching this assuming US only business.

## Stage one, the MySQL distance calculator

The acceptance criteria for stage one is that we can create a list of 
manufacturing plant locations in a table, a list of ship to addresses
in another table.  For any given ship to address we should list the 
manufacturing plant from closes to the furthest away.  This distance
will be a rough estimate based on us zip code.

https://www.youtube.com/watch?v=1K5oDtVAYzk

### What is known...
The distance calculator can only calculate distance when the general 
location of the source and destination is known.  In this exercise we will
use the US zip code to approximate the location to a latitude and longitude.
We then will use functions built into MySQL to calculate the rough distance
between the source and destination.  



To do our calculation we will need to know the latitude and longitude of
any given zip.  While you would think the US Government would readily supply
this information, that is not the case.  So we have to rely on unknown third 
parties.  In this case we will preload our zip table from a table found on 
the internet.  This table is known to be incomplete. :(

Per our best practices we will only allow addresses with known zips to be 
added to our tables.  We will do this via foreign keys.  While many see 
this as a limitation, I assure you it is not.  It will be up to the API or 
front end to add the latitude and longitude of the zip if it is not known.  
There are API for such, but may require payment.

Rough vs exact:  The goal is to return a quick "rough" shipping distance 
estimate, with the idea that this will correlate to shipping costs.  This
is intended to optimize speed over accuracy, with the results being good
enough while keeping our real time expectations.  The caching combined with
our use of limited zip to zip lookups should provide very good performance 
over time.  While a more accurate system would be more likely to degrade 
over time.

While we are using rough locations for this exercise, by abstracting the
distance calculation to the address level, we could introduce more exact 
address locations for more exact distance calculation.

This same technique could be applied to pricing from shippers to get the 
most exact costing, at the expense of a much larger dataset and slower
performance.

See:
* https://geocoding.geo.census.gov/geocoder/
* https://radar.com/product/geocoding-api
* https://developers.google.com/maps/documentation/geocoding/

## Stage one testing

* Add zip to shipping address that doesn't exist.  Should return a reference 
  error.
* Request a distance from an unknown zip.  Should return an error.
* Request a distance from a known address.  Should return a distance.
* Request a distance list using a select.  Should return a list of sites by  
  distance.

## Stage xxx multi location assembly


# Quick Start

* `docker compose up`  You will need to wait quite a bit of time as it
  pre-loads the zip geolocation table.
* Open your MySQL client to:
  * host: localhost
  * port: 5000
  * user: root
  * password: password
  * default schema: business


## Some Queries

This will list the distances from the address with id=2 to all the active 
factories.  Note: the address and city data was made up but the distance to 
the zip should be approximately accurate.

```sql
select plant_name, a2.zip as from_zip, a.zip as to_zip, address_distance(p.address_id, a.id) as dist
from us_plant_list as p
         join us_address as a
         join us_address as a2 on p.address_id = a2.id
where a.id = 2
  and p.active = true
order by dist;
```

This will give you the distance from one zip code to another if the
zip codes are both in the zip_geocode table.

```sql
select zip_distance('74571','79701');
```

# Final Notes

This is not something I have a lot of time for, this initial code was just
to scratch an itch.

My next ideas revolve around assets and material/inventory mapping.

An asset would be anything needed to make a product that is not a consumable.
So if you needed say a table saw to make a shelf, the table saw would be the
asset.

As material would be the wood needed to make the shelf.  So if you need to
make 5 shelves and each shelf needs 10 board feet and plywood.  The material
would be plywood and inventory would be how many board feet in stock at a 
given location.  So material would be a definition and inventory would be 
an amount at a location.

Inventory would also have a LIFO or FIFO cost and a "true up" to take a 
physical inventory.  This would be maintained journal entry style.

Job routing would need to have the asset(s) and inventory at a location to 
route to it.  Routing would exception break if no usable routing was 
available, ie we don't have the necessary resources/material/inventory.
