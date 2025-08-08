Select * from [HR Data]


select termdate from [HR Data]
order by termdate desc

-- Converting Datatype
update [HR Data]
set termdate = format(convert(datetime, left(termdate, 19), 120), 'yyyy-mm-dd')

--Add a new column to the table
Alter table [HR data]
Add New_TermDate date;


--Update the new column, new_termdate, with data
Update [HR Data]
set New_TermDate = 
	case 
		when termdate is not null and ISDATE(termdate) = 1 
		then cast (termdate AS datetime) 
		else null 
	end 


--Add a Column Age to the table
Alter Table [HR Data]
Add age varchar(50);



-- Populate the age column using the birthday 
update [HR Data]
Set Age = DATEDIFF(year, birthdate, getdate());


--Display the youngest age and the oldest Age that have ever worked for the company
select 
min(age) AS youngest,
max(age) AS oldest
from [HR Data]

-- Display the total of each gender in the company
Select gender, 
count (*) as count 
from [HR Data]
where New_TermDate is null
group by gender
order by gender

-- Display an age group of 10 years interval which shows the total number of current employees
select age_group, 
count(*) as count from
(select case
	when age <= 21 AND age <= 30 then '21 to 30'
	when age <= 31 AND age <= 40 then '31 to 40'
	when age <= 41 AND age <= 50 then '41 to 50'
	else '50 +'
	end as age_group
from [HR Data] 
where New_TermDate is null) AS subquery
group by age_group
order by age_group

--Gender by age group
select age_group, gender, 
count(*) as count from
(select case
	when age <= 21 AND age <= 30 then '21 to 30'
	when age <= 31 AND age <= 40 then '31 to 40'
	when age <= 41 AND age <= 50 then '41 to 50'
	else '50 +'
	end as age_group, gender
from [HR Data] 
where New_TermDate is null) AS subquery
group by age_group, gender
order by age_group, gender;

-- Gender Across Department
select department, gender, 
count(*) as count 
from [HR Data]
where New_TermDate is null
group by department, gender
order by department, gender

-- Gender by Department and Job titles 
select department, jobtitle, gender, 
count(*) as count 
from [HR Data]
where New_TermDate is null
group by department, jobtitle, gender
order by department, jobtitle, gender

-- Race Distribution
select race, 
count(*) as count 
from [HR Data]
where New_TermDate is null
group by race
order by race desc

-- Display Avg length of employment in the company
select concat(avg(DATEDIFF(year, hire_date, new_termdate)), ' Years') as Years
from [HR Data]
where New_TermDate is not null and New_TermDate <= GETDATE();


-- % Turnover rate by department 
select department, total_count, terminated_count, 
concat(round((cast(terminated_count as float)/total_count) * 100, 2), ' %')  AS Percentage_turnover_rate
from
(select department, count(*) AS  total_count, 
sum(case when new_termdate is not null and new_termdate <= GETDATE() then 1 else 0 end) AS terminated_count
from [HR Data]
group by department)
AS subqueries 
order by Percentage_turnover_rate

-- Display Avg length of employment in the company by department 
select department, 
avg(DATEDIFF(year, hire_date, new_termdate)) As Tenure 
from [HR Data]
where New_TermDate is not null and New_TermDate <= GETDATE()
group by department
order by Tenure desc


--Distribution of Employees work location 
select location, 
count(*) as count
from [HR Data]
where new_termdate is null
group by location


--Distribution of employees across different states
select 
location_state, count(*) as count
from [HR Data]
where New_TermDate is null 
group by location_state
order by count desc

-- Distribution of job titles in the company
select 
jobtitle, count(*) as count
from [HR Data]
where New_TermDate is null 
group by jobtitle
order by count desc

-- How have employee hire counts varied over time
select 
hire_year, 
hires, 
terminations, 
hires - Terminations as net_change,
concat(round((cast(hires - Terminations as float)/hires) * 100, 2), ' %')  as percent_hire_change
from
(select 
	year(hire_date) As hire_year,
	count(*) as hires,
	sum(case
	when new_termdate is not null and new_termdate <= getdate() 
	then 1 
	else 0 end
	) as Terminations 
from [HR Data]
group by year(hire_date)) As subqueries 
order by percent_hire_change
