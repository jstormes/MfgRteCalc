select plant_name, a2.zip as from_zip, a.zip as to_zip, address_distance(p.address_id, a.id) as dist
from us_plant_list as p
         join us_address as a
         join us_address as a2 on p.address_id = a2.id
where a.id = 2
  and p.active = true
order by dist;

