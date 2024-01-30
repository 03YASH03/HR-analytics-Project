create database project_hr
USE project_hr ;

select * from hr

ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;

DESCRIBE hr

SET sql_safe_updates = 0;

update hr
set birthdate= case
	when birthdate like '%/%'then date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
	when birthdate like '%-%'then date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
    else NULL
    END;
    
    
ALTER TABLE hr
modify column birthdate date;



update hr
set hire_date = case
	when hire_date like '%/%'then date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
	when hire_date like '%-%'then date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
    else NULL
    END;
    
ALTER TABLE hr
modify column hire_date date;


update hr
set termdate = date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC'))
where termdate is not null and termdate !='';

update  hr
SET termdate = null
where termdate = '';


alter table hr
add column age int

update hr
set age = timestampdiff(year,birthdate,curdate())

select min(age) , max(age) from hr



-- 1.what is the gender of thr employees in the company--

select * from hr
select gender , count(*) as count
from hr
where  termdate is null
group by gender

-- 2. What is the race breakdown of employees in the company
select * from hr
select race , count(*) as race_count
from hr
where termdate is null
group by race

-- 3. What is the age distribution of employees in the company
select * from hr
select
	case
		when age>=18 and age<=24 then '18-24'
        when age>=25 and age<=34 then '25-34'
        when age>=35 and age<=44 then '35-44'
        when age>=45 and age<=54 then '45-54'
        when age>=55 and age<=64 then '55-64'
        else '65+'
        end as 'age_group',
        count(*) as count
        from hr
        where termdate is null
        group by age_group
        order by age_group

-- 4. How many employees work at HQ vs remote
select * from hr

select location , count(*) as count
from hr
where termdate is null
group by location

-- 5. What is the average length of employement who have been teminated.
select * from hr

select round(avg(year(termdate)-year(hire_date)),0) as avg_term_length
from hr
where termdate is not null and termdate <= curdate()

-- 6. How does the gender distribution vary acorss dept. and job titles

select * from hr
select  department , jobtitle ,gender ,count(*) as count
from hr
where termdate is null
group by  department , jobtitle,gender

select  department ,gender ,count(*) as count
from hr
where termdate is null
group by  department ,gender


-- 7. What is the distribution of jobtitles acorss the company
 select * from hr
 
 select jobtitle , count(*) as count
 from hr
 where termdate is null
 group by jobtitle
 
 -- 8. Which dept has the higher turnover/termination rate
 
 select * from hr
select department ,
		count(*) as total_count,
        count(case
				when termdate is not null and termdate <= curdate() then 1
                end) as terminated_count,
		round((count(case
				when termdate is not null and termdate <= curdate() then 1
                end)/count(*))*100,2) as termination_rate
from hr
group by department
order by termination_rate desc

-- 9. What is the distribution of employees across location_state
select * from hr
                
 select location_state , count(*) as count
 from hr
 where termdate is null
 group by location_state
 
 SELECT location_city, COUNT(*) AS count
FROm hr
WHERE termdate IS NULL
GROUP BY location_city
		
-- 10. How has the companys employee count changed over time based on hire and termination date.

select * from hr

select year,
		hires,
        terminations,
        hires-terminations as net_change,
        (terminations/hires)*100 as change_percent
        from(
        select year(hire_date) as year,
        count(*) as hires,
        sum(case
			when termdate is not null and termdate <= curdate() then 1
            end) as terminations
            from hr
            group by year(hire_date)) as subquery
group by year
order by year


-- 11. What is the tenure distribution for each dept.
select * from hr
select department , round(avg(datediff(termdate,hire_date)/365),0) as avg_tenure
from hr
WHERE termdate IS NOT NULL AND termdate<= curdate()
group by department



select 
		gender,
        total_hires,
        total_terminations,
        round((total_terminations/total_hires)*100,2) as termination_rate
        from(
        select gender,
        count(*) as total_hires,
        count(case
			when termdate is not null and termdate <= curdate() then 1
            end) as total_terminations
            from hr
            group by gender) as subquery
group by gender