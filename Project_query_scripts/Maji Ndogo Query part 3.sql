use md_water_services;

drop table if exists auditor_report;

create table auditor_report(
		location_id varchar(32),
        type_of_water_source varchar(64),
        true_water_source_score int default null,
        statements varchar(255)
        );
-- import CSV 

select
	auditor_report.location_id as audit_location,
    auditor_report.true_water_source_score,
    visits.location_id as visit_location,
    visits.record_id,
    water_quality.subjective_quality_score
from 
	auditor_report
join
	visits
on auditor_report.location_id =  visits.location_id
join
	water_quality
on visits.record_id = water_quality.record_id;

select
	auditor_report.location_id as location_id,
    visits.record_id,
    auditor_report.true_water_source_score as auditor_score,
    water_quality.subjective_quality_score as surveyor_score
from 
	auditor_report
join
	visits
on auditor_report.location_id =  visits.location_id
join
	water_quality
on visits.record_id = water_quality.record_id;

select
	auditor_report.location_id as location_id,
    visits.record_id,
    auditor_report.true_water_source_score as auditor_score,
    water_quality.subjective_quality_score as surveyor_score
from 
	auditor_report
join
	visits
on auditor_report.location_id =  visits.location_id
join
	water_quality
on visits.record_id = water_quality.record_id
where  auditor_report.true_water_source_score =  water_quality.subjective_quality_score
and visits.visit_count = 1;

select
	auditor_report.location_id as location_id,
    auditor_report.type_of_water_source as auditor_source,
    water_source.type_of_water_source as survey_source,
    visits.record_id,
    auditor_report.true_water_source_score as auditor_score,
    water_quality.subjective_quality_score as surveyor_score
from 
	auditor_report
join
	visits
on auditor_report.location_id =  visits.location_id
join
	water_quality
on visits.record_id = water_quality.record_id
join
	water_source
on water_source.source_id = visits.source_id
where  auditor_report.true_water_source_score !=  water_quality.subjective_quality_score
and  visits.visit_count = 1;

select
	auditor_report.location_id as location_id,
    visits.record_id,
    employee.assigned_employee_id,
    auditor_report.true_water_source_score as auditor_score,
    water_quality.subjective_quality_score as surveyor_score
from 
	auditor_report
join
	visits
on auditor_report.location_id =  visits.location_id
join
	water_quality
on visits.record_id = water_quality.record_id
join 
	employee
on visits.assigned_employee_id = employee.assigned_employee_id
where  auditor_report.true_water_source_score !=  water_quality.subjective_quality_score
and  visits.visit_count = 1;

with  incorrect_record as (	select
							auditor_report.location_id as location_id,
							visits.record_id,
							employee.employee_name,
							auditor_report.true_water_source_score as auditor_score,
							water_quality.subjective_quality_score as surveyor_score
						from 
							auditor_report
						join
							visits
						on auditor_report.location_id =  visits.location_id
						join
							water_quality
						on visits.record_id = water_quality.record_id
						join 
							employee
						on visits.assigned_employee_id = employee.assigned_employee_id
						where  auditor_report.true_water_source_score !=  water_quality.subjective_quality_score
						and  visits.visit_count = 1 ) 
select * from incorrect_record;

with  incorrect_record as (	select
							auditor_report.location_id as location_id,
							visits.record_id,
							employee.employee_name,
							auditor_report.true_water_source_score as auditor_score,
							water_quality.subjective_quality_score as surveyor_score
						from 
							auditor_report
						join
							visits
						on auditor_report.location_id =  visits.location_id
						join
							water_quality
						on visits.record_id = water_quality.record_id
						join 
							employee
						on visits.assigned_employee_id = employee.assigned_employee_id
						where  auditor_report.true_water_source_score !=  water_quality.subjective_quality_score
						and  visits.visit_count = 1 ) 
select distinct 
	employee_name,
    count(employee_name) as number_of_mistake
from incorrect_record
group by employee_name;


create view  incorrect_record as (	select
							auditor_report.location_id as location_id,
							visits.record_id,
							employee.employee_name,
							auditor_report.true_water_source_score as auditor_score,
							wq.subjective_quality_score as surveyor_score,
                            auditor_report.statements AS statements
						from 
							auditor_report
						join
							visits
						on auditor_report.location_id =  visits.location_id
						join
							water_quality as wq
						on visits.record_id = wq.record_id
						join 
							employee
						on visits.assigned_employee_id = employee.assigned_employee_id
						where  auditor_report.true_water_source_score !=  wq.subjective_quality_score
						and  visits.visit_count = 1 ) ;


with suspect_list as ( WITH error_count AS (
				SELECT
					employee_name,
					COUNT(employee_name) AS number_of_mistakes
				FROM
					incorrect_record
				GROUP BY
					employee_name)
select 
	employee_name,
	number_of_mistakes
from 
	error_count
where number_of_mistakes > (
		SELECT 
			avg(number_of_mistakes) as avg_of_mistakes
		FROM error_count))
select employee_name from suspect_list ;


WITH error_count AS (
				SELECT
					employee_name,
					COUNT(employee_name) AS number_of_mistakes
				FROM
					incorrect_record
				GROUP BY
					employee_name)
select 
	employee_name,
	number_of_mistakes
from 
	error_count
where number_of_mistakes > (
		SELECT 
			avg(number_of_mistakes) as avg_of_mistakes);


with suspect_list as ( WITH error_count AS (
				SELECT
					employee_name,
					COUNT(employee_name) AS number_of_mistakes
				FROM
					incorrect_record
				GROUP BY
					employee_name)
select 
	employee_name,
	number_of_mistakes
from 
	error_count
where number_of_mistakes > (
		SELECT 
			avg(number_of_mistakes) as avg_of_mistakes
		FROM error_count))
select employee_name from suspect_list ;

WITH error_count AS ( 
						SELECT
						employee_name,
						COUNT(employee_name) AS number_of_mistakes
						FROM
						Incorrect_record
						GROUP BY
						employee_name),
suspect_list AS (
						SELECT
						employee_name,
						number_of_mistakes
						FROM
						error_count
						WHERE
						number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count))
SELECT
		employee_name,
		location_id,
		statements
FROM
	incorrect_record
WHERE
	employee_name in (SELECT employee_name FROM suspect_list);