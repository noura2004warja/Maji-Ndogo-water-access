use md_water_services;

SELECT distinct
	type_of_water_source
from
	water_source;
    
select *
from visits
where time_in_queue >= 500;

select *
from visits
where time_in_queue = 0;

select
	count(*)
from water_quality
where	subjective_quality_score = 10
AND visit_count = 2;

select *
from well_pollution
where results ='Clean'
AND biological > 0.01;

select *
from well_pollution
where description like 'Clean%'
AND  biological > 0.01;

select *
from well_pollution
	-- case 1a
Update
	well_pollution
set description = 'Bacteria:E.Coli'
where description = 'Clean Bacteria: E.Coli'
	-- case 1b
Update 
	well_pollution
set description = 'Bacteria:Giardia Liamblia'
where description = 'Clean Bacteria: Giardia Liamblia'
	-- case 2
Update 
	well_pollution
set results = 'Contaminated:Biological'
where biological > 0.01
AND results = 'Clean';


create table md_water_services.well_pollution_copy
AS (select * 
	from md_water_services.well_pollution);