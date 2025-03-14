use md_water_services;


INSERT INTO project_progress (
    Address, Town, Province, source_id, Source_type, Improvement
)
SELECT 
    location.address,
    location.town_name,
    location.province_name,
    water_source.source_id,
    water_source.type_of_water_source,
    CASE
        WHEN well_pollution.results = 'Contaminated: Chemical' THEN 'Install RO filter' 
        WHEN well_pollution.results = 'Contaminated: Biological' THEN 'Install UV and RO filter' 
        WHEN water_source.type_of_water_source = 'river' THEN 'drill wells' 
        WHEN type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30 THEN CONCAT("Install ", FLOOR((visits.time_in_queue)/30), " taps nearby")
        WHEN water_source.type_of_water_source = 'tap_in_home_broken' THEN 'diagnose infrastructure'
        ELSE NULL
    END AS Improvement
FROM 
    water_source
LEFT JOIN 
    well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN 
    visits ON water_source.source_id = visits.source_id
INNER JOIN 
    location ON location.location_id = visits.location_id
WHERE
    visits.visit_count = 1
    AND (
        well_pollution.results IS NOT NULL AND well_pollution.results != 'Clean'
        OR water_source.type_of_water_source IN ('tap_in_home_broken', 'river')
        OR (water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30)
    );
    
    
    WITH province_totals AS (-- This CTE calculates the population of each province
SELECT
	province_name,
	SUM(people_served) AS total_ppl_serv
FROM
	combined_analysis_table
GROUP BY
	province_name
)

SELECT
	ct.province_name,
-- These case statements create columns for each type of source.
-- The results are aggregated and percentages are calculated
		ROUND((SUM(CASE WHEN source_type = 'river'
		THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
		ROUND((SUM(CASE WHEN source_type = 'shared_tap'
		THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
		ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
		THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
		ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
		THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
		ROUND((SUM(CASE WHEN source_type = 'well'
		THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM
	combined_analysis_table ct
JOIN
	province_totals pt 
ON ct.province_name = pt.province_name
GROUP BY
	ct.province_name
ORDER BY
	ct.province_name;
    
    
WITH town_totals AS ( -- This CTE calculates the population of each town
-- Since there are two Harare towns, we have to group by province_name and town_name
						SELECT 
							province_name,
							town_name,
							SUM(people_served) AS total_ppl_serv
						FROM 	
							combined_analysis_table
						GROUP BY 
							province_name,
							town_name
)
SELECT
		ct.province_name,
		ct.town_name,
		ROUND((SUM(CASE WHEN source_type = 'river'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
		ROUND((SUM(CASE WHEN source_type = 'shared_tap'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
		ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
		ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
		ROUND((SUM(CASE WHEN source_type = 'well'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
	combined_analysis_table ct
JOIN -- Since the town names are not unique, we have to join on a composite key
	town_totals tt 
ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY -- We group by province first, then by town.
	ct.province_name,
	ct.town_name
ORDER BY
	ct.town_name;
    

create temporary table town_aggregated_water_access
WITH town_totals AS ( -- This CTE calculates the population of each town
-- Since there are two Harare towns, we have to group by province_name and town_name
						SELECT 
							province_name,
							town_name,
							SUM(people_served) AS total_ppl_serv
						FROM 	
							combined_analysis_table
						GROUP BY 
							province_name,
							town_name
)
SELECT
		ct.province_name,
		ct.town_name,
		ROUND((SUM(CASE WHEN source_type = 'river'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
		ROUND((SUM(CASE WHEN source_type = 'shared_tap'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
		ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
		ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
		ROUND((SUM(CASE WHEN source_type = 'well'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
	combined_analysis_table ct
JOIN -- Since the town names are not unique, we have to join on a composite key
	town_totals tt 
ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY -- We group by province first, then by town.
	ct.province_name,
	ct.town_name
ORDER BY
	ct.town_name;
select * from town_aggregated_water_access;


SELECT 
    province_name,
    town_name,
    ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) * 100,
            0) AS Pct_broken_taps
FROM
    town_aggregated_water_access;
    
    
    CREATE TABLE Project_progress (
Project_id SERIAL PRIMARY KEY,
source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
Address VARCHAR(50),
Town VARCHAR(30),
Province VARCHAR(30),
Source_type VARCHAR(50),
Improvement VARCHAR(50),
Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
Date_of_completion DATE,
Comments TEXT
);
    SELECT 
    location.address,
    location.town_name,
    location.province_name,
    water_source.source_id,
    water_source.type_of_water_source,
    well_pollution.results
FROM
    water_source
        LEFT JOIN
    well_pollution ON water_source.source_id = well_pollution.source_id
        INNER JOIN
    visits ON water_source.source_id = visits.source_id
        INNER JOIN
    location ON location.location_id = visits.location_id;
    
    
    INSERT INTO project_progress (
    Address, Town, Province, source_id, Source_type, Improvement
)
SELECT 
    location.address,
    location.town_name,
    location.province_name,
    water_source.source_id,
    water_source.type_of_water_source,
    CASE
        WHEN well_pollution.results = 'Contaminated: Chemical' THEN 'Install RO filter' 
        WHEN well_pollution.results = 'Contaminated: Biological' THEN 'Install UV and RO filter' 
        WHEN water_source.type_of_water_source = 'river' THEN 'drill wells' 
        WHEN type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30 THEN CONCAT("Install ", FLOOR((visits.time_in_queue)/30), " taps nearby")
        WHEN water_source.type_of_water_source = 'tap_in_home_broken' THEN 'diagnose infrastructure'
        ELSE NULL
    END AS Improvement
FROM 
    water_source
LEFT JOIN 
    well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN 
    visits ON water_source.source_id = visits.source_id
INNER JOIN 
    location ON location.location_id = visits.location_id
WHERE
    visits.visit_count = 1
    AND (
        well_pollution.results IS NOT NULL AND well_pollution.results != 'Clean'
        OR water_source.type_of_water_source IN ('tap_in_home_broken', 'river')
        OR (water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30)
    );