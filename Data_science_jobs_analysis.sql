-- 1. You're a Compensation analyst employed by a multinational corporation. Your Assignment is to Pinpoint Countries who give work fully remotely, 
--    for the title 'managers’ Paying salaries Exceeding $90,000 USD.

SELECT DISTINCT(company_locatiON) 
FROM salaries 
WHERE job_title LIKE '%Manager%'AND salary_IN_usd > 90000 AND remote_ratio= 100;


-- 2. AS a remote work advocate Working for a progressive HR tech startup who place their freshers’ clients IN large tech firms. you're tasked WITH 
--    Identifying top 5 Country Having  greatest count of large(company size) number of companies.

SELECT company_location, COUNT(company_size) AS 'cnt' 
FROM ( SELECT * FROM salaries WHERE experience_level ='EN' AND company_size='L' ) AS t  
GROUP BY company_location
ORDER BY cnt DESC
LIMIT 5;


-- 3. Picture yourself AS a data scientist Working for a workforce management platform. Your objective is to calculate the percentage of employees. 
--    Who enjoy fully remote roles WITH salaries Exceeding $100,000 USD, Shedding light ON the attractiveness of high-paying remote positions IN
--    today's job market.

SET @COUNT= (SELECT COUNT(*) FROM salaries  WHERE salary_in_usd >100000 and remote_ratio=100);
SET @total = (SELECT COUNT(*) FROM salaries where salary_in_usd>100000);
SET @percentage= round((((SELECT @COUNT)/(SELECT @total))*100),2);
SELECT @percentage AS '%  of people working remotely and having salary >100,000 USD';


-- 4.Imagine you're a data analyst Working for a global recruitment agency. Your Task is to identify the Locations where entry-level average salaries exceed the 
--   average salary for that job title in market for entry level, helping your agency guide candidates towards lucrative countries.

SELECT company_locatiON, t.job_title, average_per_country, average FROM 
(
	SELECT company_location,job_title,AVG(salary_IN_usd) AS average_per_country FROM  salaries WHERE experience_level = 'EN' 
	GROUP BY  company_locatiON, job_title
) AS t 
INNER JOIN 
( 
	 SELECT job_title,AVG(salary_IN_usd) AS average FROM  salaries  WHERE experience_level = 'EN'  GROUP BY job_title
) AS p 
ON  t.job_title = p.job_title WHERE average_per_country> average;


-- 5. You've been hired by a big HR Consultancy to look at how much people get paid IN different Countries. Your job is to Find out for each job title which
--    Country pays the maximum average salary. This helps you to place your candidates IN those countries.

SELECT company_locatiON , job_title , average FROM
(
SELECT *, dense_rank() over (partitiON by job_title order by average desc)  AS num FROM 
(
SELECT company_locatiON , job_title , AVG(salary_IN_usd) AS 'average' FROM salaries GROUP BY company_locatiON, job_title
)k
)t  WHERE num=1;


-- 6. AS a data-driven Business consultant, you've been hired by a multinational corporation to analyze salary trends across different company Locations.
 --   Your goal is to Pinpoint Locations WHERE the average salary Has consistently Increased over the Past few years (Countries WHERE data is available for 
 --   3 years Only(this and past two years) providing Insights into Locations experiencing Sustained salary growth.


WITH t AS
(
 SELECT * FROM  salaries WHERE company_locatiON IN
		(
			SELECT company_locatiON FROM
			(
				SELECT company_locatiON, AVG(salary_IN_usd) AS AVG_salary,COUNT(DISTINCT (work_year)) AS num_years FROM salaries WHERE work_year >= YEAR(CURRENT_DATE()) - 2
				GROUP BY  company_locatiON HAVING  num_years = 3 
			)m
		)
) 



SELECT  company_location, 
		MAX(CASE WHEN work_year = 2022 THEN average END) AS AVG_salary_2022,
		MAX(CASE WHEN work_year = 2023 THEN average END) AS AVG_salary_2023,
		MAX(CASE WHEN work_year = 2024 THEN average END) AS AVG_salary_2024
FROM ( SELECT company_location, work_year, AVG(salary_in_usd) average FROM t GROUP BY company_location, work_year ) a
GROUP BY company_location
HAVING AVG_salary_2022 < AVG_salary_2023 AND AVG_salary_2023 < AVG_salary_2024;


-- 7. Picture yourself AS a workforce strategist employed by a global HR tech startup. Your missiON is to determINe the percentage of  fully remote work for each 
 --   experience level IN 2021 and compare it WITH the correspONdINg figures for 2024, highlightINg any significant INcreASes or decreASes IN remote work adoptiON
--    over the years.

	WITH t1 AS (

					SELECT a.experience_level, Fully_remote_work_21, Total_21
					FROM 
						(	SELECT experience_level , COUNT(*) AS Fully_remote_work_21
							FROM salaries
							WHERE remote_ratio = 100 AND work_year = 2021
							GROUP BY experience_level ) a
							
							JOIN

						(	SELECT experience_level , COUNT(*) AS Total_21
							FROM salaries
							WHERE work_year = 2021
							GROUP BY experience_level ) b
						
						ON a.experience_level = b.experience_level
					
				),
                
	t2 AS (

							SELECT a.experience_level, Fully_remote_work_24, Total_24
							FROM 
								(	SELECT experience_level , COUNT(*) AS Fully_remote_work_24
									FROM salaries
									WHERE remote_ratio = 100 AND work_year = 2024
									GROUP BY experience_level ) a
									
									JOIN

								(	SELECT experience_level , COUNT(*) AS Total_24
									FROM salaries
									WHERE work_year = 2024
									GROUP BY experience_level ) b
								
								ON a.experience_level = b.experience_level
							)
							
				
SELECT a.experience_level, ROUND((Fully_remote_work_21/Total_21)*100,2) AS remote_21, ROUND((Fully_remote_work_24/Total_24)*100,2) AS remote_24
FROM (( SELECT * FROM t1 )a JOIN ( SELECT * FROM t2 )b ON a.experience_level = b.experience_level);


-- 8. AS a compensation specialist at a Fortune 500 company, you're tasked with analyzing salary trends over time. Your objective is to calculate the average 
--    salary increase percentage for each experience level and job title between the years 2023 and 2024, helping the company stay competitive in the talent market.

WITH t AS
	(	SELECT job_title, experience_level,
		ROUND(AVG(CASE WHEN work_year = 2023 THEN salary_in_usd END),2) AS Avg_salary_23,
		ROUND(AVG(CASE WHEN work_year = 2024 THEN salary_in_usd END),2) AS Avg_salary_24
		FROM salaries
		WHERE work_year = 2023 OR work_year = 2024
		GROUP BY job_title, experience_level
	)
    
SELECT *, ROUND(((Avg_salary_24 - Avg_salary_23) / Avg_salary_24)*100,2) AS growth_pct
FROM t;


-- 9.As a market researcher, your job is to Investigate the job market for a company that analyzes workforce data. 
--   Your Task is to know how many people were employed IN different types of companies AS per their size IN 2021.

SELECT company_size, COUNT(company_size) AS 'COUNT of employees' 
FROM salaries 
WHERE work_year = 2021 
GROUP BY company_size;


-- 10.Imagine you are a talent Acquisition specialist Working for an International recruitment agency.
--    Your Task is to identify the top 3 job titles that command the highest average salary Among part-time Positions.

SELECT job_title, AVG(salary_in_usd) AS Avg_salary
FROM salaries
WHERE employment_type LIKE 'PT' 
GROUP BY job_title
ORDER BY Avg_salary DESC
LIMIT 3;

-- 11.As a database analyst you have been assigned the task to Select Countries where average mid-level salary
--    is higher than overall mid-level salary for the year 2023.

	SET @overall =( SELECT AVG(salary_in_usd)
				    FROM salaries
				    WHERE experience_level LIKE 'MI' AND work_year = 2023 );


SELECT company_location, ROUND(AVG(salary_in_usd),2) AS Avg_salary
FROM salaries
WHERE experience_level LIKE 'MI' AND work_year = 2023
GROUP BY company_location
HAVING Avg_salary > @overall
ORDER BY Avg_salary DESC;

-- 12.As a database analyst you have been assigned the task to Identify the company locations with the highest and lowest average salary for 
--    senior-level (SE) employees in 2023.

-- To get the highest average salary.
SELECT company_location, AVG(salary_in_usd) avg_salary 
FROM salaries
WHERE experience_level = 'SE' AND work_year = 2023
GROUP BY company_location
ORDER BY avg_salary DESC
LIMIT 1; 


-- To get the lowest average salary.
SELECT company_location, AVG(salary_in_usd) avg_salary 
FROM salaries
WHERE experience_level = 'SE' AND work_year = 2023
GROUP BY company_location
ORDER BY avg_salary 
LIMIT 1;


-- 13.You're a Financial analyst Working for a leading HR Consultancy, and your Task is to Assess the annual salary growth rate for various job titles. 
--    By Calculating the percentage Increase IN salary FROM previous year to this year, you aim to provide valuable Insights Into salary trends WITHIN 
--    different job roles.

WITH t AS (SELECT job_title,
		   AVG(CASE WHEN work_year = 2023 THEN salary_in_usd END) AS avg_salary_2023,
		   AVG(CASE WHEN work_year = 2024 THEN salary_in_usd END) AS avg_salary_2024
		   FROM salaries
		   GROUP BY job_title)
		
SELECT *, ROUND(((avg_salary_2024 - avg_salary_2023)/avg_salary_2024)*100,2) AS percentage_change
FROM t;


-- 14.You've been hired by a global HR Consultancy to identify Countries experiencing significant salary growth for entry-level roles. 
--    Your task is to list the top three Countries with the highest salary growth rate FROM 2021 to 2023, helping multinational Corporations 
--    identify  Emerging talent markets.


	SELECT  company_location, Avg_salary_2021, Avg_salary_2023, ROUND(((Avg_salary_2023 - Avg_salary_2021)/Avg_salary_2023)*100,2) AS 'changes'
	FROM	(	WITH t AS (SELECT company_location, salary_in_usd , work_year
					   FROM salaries
					   WHERE (experience_level LIKE 'EN') AND (work_year = 2021 OR work_year = 2023))
					   
			SELECT company_location, 
			ROUND(AVG(CASE WHEN work_year = 2021 THEN salary_in_usd END),2) AS Avg_salary_2021,
			ROUND(AVG(CASE WHEN work_year = 2023 THEN salary_in_usd END),2) AS Avg_salary_2023
			FROM t
			GROUP BY company_location
			) a
	 WHERE ROUND(((Avg_salary_2023 - Avg_salary_2021)/Avg_salary_2023)*100,2) IS NOT NULL;
            
-- 15.Picture yourself as a data architect responsible for database management. 
--   Companies in US and AU(Australia) decided to create a hybrid model for employees 
--   they decided that employees earning salaries exceeding $90000 USD, will be given work from home. 
--   You now need to update the remote work ratio for eligible employees,
--   ensuring efficient remote work management while implementing appropriate error handling mechanisms for invalid input parameters.

create  table temp  AS SELECT * FROM salaries;  -- creating temporary table so that changes are not made in actual table as actual table is being used in other cases also.


-- by default mysql runs on safe update mode , this mode  is a safeguard against updating
-- or deleting large portion of  a table.
-- We will turn off safe update mode using set_sql_safe_updates
 
SET SQL_SAFE_UPDATES = 0;

UPDATE temp
SET remote_ratio = 100
WHERE (company_location = 'AU' OR company_location ='US')AND salary_in_usd > 90000;

-- 16.In year 2024, due to increase demand in data industry , there was  increase in salaries of data field employees.
--    Entry Level-35%  of the salary.
--    Mid junior – 30% of the salary.
--    Immediate senior level- 22% of the salary.
--    Expert level- 20% of the salary.
--    Director – 15% of the salary.
--    you have to update the salaries accordingly and update it back in the original database.

UPDATE temp
SET salary_in_usd = 
    CASE 
        WHEN experience_level = 'EN' THEN salary_in_usd * 1.35  -- Increase salary for Entry Level by 35%
        WHEN experience_level = 'MI' THEN salary_in_usd * 1.30  -- Increase salary for Mid Junior by 30%
        WHEN experience_level = 'SE' THEN salary_in_usd * 1.22  -- Increase salary for Immediate Senior Level by 22%
        WHEN experience_level = 'EX' THEN salary_in_usd * 1.20  -- Increase salary for Expert Level by 20%
        WHEN experience_level = 'DX' THEN salary_in_usd * 1.15  -- Increase salary for Director by 15%
        ELSE salary_in_usd  -- Keep salary unchanged for other experience levels
    END
WHERE work_year = 2024;  -- Update salaries only for the year 2024;


-- 17 You are a researcher and you have been assigned the task to Find the year with the highest average salary for each job title.

SELECT job_title, work_year, avg_salary FROM 
(	WITH Avg_salary AS
	(SELECT job_title, work_year, AVG(salary_in_usd) Avg_salary
	 FROM   salaries
	 GROUP BY job_title, work_year)
	 
	 SELECT job_title, work_year, avg_salary, RANK() OVER (PARTITION BY job_title ORDER BY avg_salary DESC) AS rank_by_salary
	 FROM Avg_salary
)a
WHERE rank_by_salary = 1; -- Select the records where the rank of average salary is 1 (highest) 

-- 18.You have been hired by a market research agency where you been assigned the task to show the 
--    percentage of different employment type (full time, part time) in Different job roles, 
--    in the format where each row will be job title, each column will be type of employment type and  
--    cell value  for that row and column will show the % value

SELECT 
    job_title,
    ROUND((SUM(CASE WHEN employment_type = 'PT' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS PT_percentage, -- Calculate percentage of part-time employment
    ROUND((SUM(CASE WHEN employment_type = 'FT' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS FT_percentage, -- Calculate percentage of full-time employment
    ROUND((SUM(CASE WHEN employment_type = 'CT' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS CT_percentage, -- Calculate percentage of contract employment
    ROUND((SUM(CASE WHEN employment_type = 'FL' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS FL_percentage -- Calculate percentage of freelance employment
FROM 
    salaries
GROUP BY 
    job_title; -- Group the result by job title
