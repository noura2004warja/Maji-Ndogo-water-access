use md_water_services;

select
	concat(lower(replace(employee_name,' ','.')),'@ndogowater.gov') 
	as New_email
from employee;

update employee
set email = concat(lower(replace(employee_name,' ','.')),'@ndogowater.gov') ;

select 
	length(phone_number)
from employee;

select trim(phone_number) 
	as New_phone_number
from employee;

update employee
set phone_number = trim(phone_number); 

select distinct 
	town_name,
    count(employee_name) over (partition by town_name) as num_employee
from employee
order by town_name;

select distinct
	assigned_employee_id,
    count(record_id) over (partition by assigned_employee_id) as number_of_visits
from visits
order by number_of_visits desc
limit 3 ;

select 
	assigned_employee_id,
    employee_name,
    phone_number,
    email,
    address
from employee
where assigned_employee_id in (1,30,34);

select 
	count(location_id) as record_per_town,
    town_name
from location
group by town_name;

select 
	count(location_id) as record_per_town,
	province_name
from location
group by province_name;

select distinct 
	province_name,
    town_name,
    count(location_id) over ( partition by province_name,town_name
							  order by province_name desc )
                              as records_per_town
from location
order by records_per_town desc;

select distinct 
	count(location_id) as num_of_sources,
    location_type
from location
group by location_type;

select round(23740/(15910 + 23740)*100,2);

select 
	sum(number_of_people_served) as total_people 
    from water_source;

select 
	type_of_water_source,
    count(type_of_water_source) as number_of_sources
from 
	water_source
group by type_of_water_source;

select 
	type_of_water_source,
    round(avg(number_of_people_served),0) as avg_people_per_source
from water_source
group by type_of_water_source;

select
	type_of_water_source,
    sum(number_of_people_served) as population
from water_source
group by type_of_water_source;
    
select 
	type_of_water_source,
    round((sum(number_of_people_served)/27628140),0)*100 as pct_population_served -- 27628140 is the total population
from water_source
group by type_of_water_source;

select
	type_of_water_source,
    sum(number_of_people_served) as population_served,
    rank() over (order by sum(number_of_people_served) desc ) as rank_population
from water_source
where type_of_water_source != 'tap_in_home'
group by type_of_water_source;

select 
	source_id,
    type_of_water_source,
    rank() over (partition by type_of_water_source 
				 order by number_of_people_served desc) as priority_rank
from water_source
where type_of_water_source != 'tap_in_home';

select 
	max(time_of_record) as last_date,
    min(time_of_record) as first_date,
    datediff(max(time_of_record), min(time_of_record)) as survey_period
from
	visits;
    
select 
	avg(nullif(time_in_queue,0)) as avg_queue_time
from visits;

select 
	dayname(time_of_record) as day_of_week,
    round(avg(nullif(time_in_queue,0)),0) as avg_queue_time
from visits 
group by day_of_week ;

select
	time_format(time(time_of_record),'%H:00') as hour_of_day,
    round(avg(nullif(time_in_queue,0)),0) as avg_queue_time
from visits
group by hour_of_day;