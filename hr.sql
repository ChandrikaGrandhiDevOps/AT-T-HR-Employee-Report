CREATE DATABASE project;

USE project;

SELECT * FROM hr;

ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;

DESCRIBE hr;

SELECT birthdate FROM hr;

SET sql_safe_updates = 0;

SELECT birthdate FROM hr;

SET sql_safe_updates = 0;

UPDATE hr
SET birthdate = CASE
WHEN birthdate LIKE 



UPDATE hr
SET birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN birthdate DATE;

UPDATE hr
SET hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;


UPDATE hr 
SET termdate = DATE(STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC')) 
WHERE termdate IS NOT NULL 
  AND termdate != '' 
  AND termdate != ' ';



UPDATE hr
SET termdate = NULL
WHERE termdate = '' OR termdate = ' ';

ALTER TABLE hr ADD COLUMN age INT;

UPDATE hr
SET age = timestampdiff(YEAR, birthdate, CURDATE());

SELECT 
	min(age) AS youngest,
    max(age) AS oldest
FROM hr;

SELECT count(*) FROM hr WHERE age < 18;

SELECT COUNT(*) FROM hr WHERE termdate > CURDATE();

SELECT COUNT(*)
FROM hr
WHERE termdate = '0000-00-00';

SELECT location FROM hr;


-- QUESTIONS

-- 1. What is the gender breakdown of employees in the company?
SELECT 
    gender,
    COUNT(*) AS gendercount
FROM
    hr
WHERE
    FLOOR(DATEDIFF(CURDATE(), birthdate) / 365.25) >= 18
    AND (termdate IS NULL OR termdate = '')
GROUP BY 
    gender;


SELECT * FROM hr LIMIT 2;
-- 2. What is the race/ethnicity breakdown of employees in the company?
SELECT gender, race, count(*) as racecount
from hr
WHERE
    FLOOR(DATEDIFF(CURDATE(), birthdate) / 365.25) >= 18
    AND (termdate IS NULL OR termdate = '')
group by gender, race;
-- 3. What is the age distribution of employees in the company?
SELECT 
    CASE
        WHEN FLOOR(DATEDIFF(CURDATE(), birthdate) / 365.25) BETWEEN 18 AND 24 THEN '18-24'
        WHEN FLOOR(DATEDIFF(CURDATE(), birthdate) / 365.25) BETWEEN 25 AND 34 THEN '25-34'
        WHEN FLOOR(DATEDIFF(CURDATE(), birthdate) / 365.25) BETWEEN 35 AND 44 THEN '35-44'
        WHEN FLOOR(DATEDIFF(CURDATE(), birthdate) / 365.25) BETWEEN 45 AND 54 THEN '45-54'
        WHEN FLOOR(DATEDIFF(CURDATE(), birthdate) / 365.25) BETWEEN 55 AND 64 THEN '55-64'
        WHEN FLOOR(DATEDIFF(CURDATE(), birthdate) / 365.25) >= 65 THEN '65+'
        ELSE 'Unknown'
    END AS age_group, gender,
    COUNT(*) AS employee_count
FROM 
    hr
WHERE 
    birthdate IS NOT NULL
GROUP BY 
    age_group,gender
ORDER BY 
    age_group,gender;


-- 4. How many employees work at headquarters versus remote locations?
select location, count(*) as count
from hr
where FLOOR(DATEDIFF(CURDATE(), birthdate) / 365.25) >= 18
    AND (termdate IS NULL OR termdate = '')
group by location;    


-- 5. What is the average length of employment for employees who have been terminated?

SELECT 
    round(AVG(DATEDIFF(termdate, hire_date))/365,0) AS avg_length_employment_days
FROM 
    hr
WHERE 
    termdate <= curdate() AND termdate <> '0000-00-00' AND age>=18

-- 6. How does the gender distribution vary across departments and job titles? 
SELECT
    department,
    gender,
    COUNT(*) AS gender_count
FROM 
    hr
WHERE 
    FLOOR(DATEDIFF(CURDATE(), birthdate) / 365.25) >= 18
    AND (termdate IS NULL OR termdate = '')
GROUP BY 
    department,
    gender
ORDER BY 
    department,
    gender;

-- 7. What is the distribution of job titles across the company?
SELECT 
    jobtitle,
    COUNT(*) AS job_count
FROM 
    hr
GROUP BY 
    jobtitle
ORDER BY 
    job_count DESC;

SELECT * FROM hr LIMIT 2;
-- 8. Which department has the highest turnover rate?

SELECT 
    department,
    COUNT(CASE WHEN termdate IS NOT NULL AND termdate != '' THEN 1 ELSE NULL END) AS terminated_count,
    COUNT(*) AS total_employees,
    ROUND((COUNT(CASE WHEN termdate IS NOT NULL AND termdate != '' THEN 1 ELSE NULL END) / COUNT(*)) * 100, 2) AS turnover_rate
FROM 
    hr
GROUP BY 
    department
ORDER BY 
    turnover_rate DESC;

-- 9. What is the distribution of employees across locations by city and state?
SELECT 
    location_city,
    location_state,
    COUNT(*) AS employee_count
FROM 
    hr
GROUP BY 
    location_city, location_state
ORDER BY 
    employee_count DESC;


-- 10. How has the company's employee count changed over time based on hire and term dates?
SELECT year, hires, terminations, hires-terminations as net_change,
round((hires-terminations)/hires*100,2) as net_change_percent
FROM( SELECT year(hire_date) as year,
     COUNT(*) as hires,
     SUM(CASE WHEN termdate<>'0000-00-00' AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminations
     FROM hr
     WHERE age >= 18
     group by year(hire_date)
     ) AS subquery
     order by year ASC;
     

SELECT * FROM hr LIMIT 2;

-- 11. What is the tenure distribution for each department?

SELECT 
    department,
    FLOOR(DATEDIFF(COALESCE(termdate, CURDATE()), hire_date) / 365) AS years_of_tenure,
    COUNT(*) AS employee_count
FROM 
    hr
WHERE 
    hire_date IS NOT NULL
GROUP BY 
    department, years_of_tenure
ORDER BY 
    department, years_of_tenure;
