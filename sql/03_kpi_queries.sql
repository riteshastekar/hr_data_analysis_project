-- 1.WHAT IS THE GENDER BREAKDOWN OF EMPLOYEE IN THE COMPANY
CREATE VIEW gender AS
SELECT gender,COUNT(*) AS count_gen
FROM hr
WHERE termdate IS NULL
GROUP BY gender 


-- 2.WHAT IS THE RACE BREAKDOWN OF THE EMPLOYEE IN THE COMPANY
CREATE VIEW race_breakdown AS
SELECT race,COUNT(*) AS count_race
FROM hr
WHERE termdate IS NULL
GROUP BY race 


-- 3.WHAT IS THE AGE DISTRIBUTION OF EMPLOYEES IN COMPANY
CREATE VIEW age_distribution AS
SELECT age_group,COUNT(*) as counts FROM
(SELECT *,
	CASE	
		WHEN age>=18 AND age<=24 THEN '18-24'
		WHEN age>=25 AND age<=34 THEN '25-34'
		WHEN age>=35 AND age<=44 THEN '35-44'
		WHEN age>=45 AND age<=54 THEN '45-54'
		WHEN age>=55 AND age<=64 THEN '55-64'
		ELSE '65+'
END AS age_group
FROM hr
WHERE termdate IS NULL ) o
GROUP BY age_group


-- 4. HOW MANY EMPLOYEES WORK AT HQ VS REMOTE
CREATE VIEW  hq_VS_re AS
SELECT location,COUNT(*) AS counts FROM hr
WHERE termdate IS NULL
GROUP BY location


-- 5. WHAT IS AVERAGE LENGTH OF THE EMPLOYMENT WHO HAVE BEEN TERMINATED
CREATE VIEW vw_avg_length_of_employment AS
SELECT ROUND(AVG(DATEDIFF(YEAR, hire_date, termdate)), 0) AS length_of_employment
FROM hr
WHERE termdate IS NOT NULL AND termdate <= GETDATE();
GO


-- 6. HOW DOES GENDER DISTRIBUTION VARY ACROSS DEPT. AND JOBTITLE
CREATE VIEW vw_gender_distribution_by_dept_jobtitle AS
SELECT department, jobtitle, gender, COUNT(*) AS counts
FROM hr
WHERE termdate IS NULL
GROUP BY department, jobtitle, gender;
GO
--by DEPT ONLY
CREATE VIEW vw_gender_distribution_by_dept AS
SELECT department, gender, COUNT(*) AS counts
FROM hr
WHERE termdate IS NULL
GROUP BY department,gender;
GO


-- 7. WHAT IS THE DISTRIBUTION OF JOBTITLE ACROSS THE COMPANY
CREATE VIEW vw_jobtitle_distribution AS
SELECT jobtitle, COUNT(*) AS counts
FROM hr
WHERE termdate IS NULL
GROUP BY jobtitle;
GO


-- 8. WHICH DEPT HAS THE HIGHER TURNOVER/TERMINATION RATE
CREATE VIEW vw_termination_rate_by_dept AS
SELECT  department,
		COUNT(*) AS total_count,
		COUNT(CASE
				   WHEN termdate IS NOT NULL AND termdate <= GETDATE() THEN 1
				   END) AS terminated_count,
		ROUND(COUNT(CASE
						 WHEN termdate IS NOT NULL AND termdate <= GETDATE() THEN 1
						 END) * 100.0 / COUNT(*), 2) AS termination_rate
FROM hr
GROUP BY department;
GO


-- 9. WHAT IS THE DISTRIBUTION OF EMPLOYEES ACROSS LOCATION_STATE
CREATE VIEW vw_employee_distribution_by_state AS
SELECT location_state, COUNT(*) AS counts
FROM hr
WHERE termdate IS NULL
GROUP BY location_state;
GO

-- BY CITY
CREATE VIEW vw_employee_distribution_by_city AS
SELECT location_city, COUNT(*) AS counts
FROM hr
WHERE termdate IS NULL
GROUP BY location_city;
GO


-- 10. HOW HAS THE COMPANY'S EMPLOYEE COUNT CHANGED OVER TIME BASED ON HIRE AND TERMINATION DATE
CREATE VIEW vw_employee_count_change_over_time AS
SELECT years,
	   hires,
	   terminations,
	   hires - terminations AS net_change,
	   (terminations*100.0/hires) AS change_percent
FROM (
	SELECT YEAR(hire_date) AS years,
		   COUNT(*) AS hires,
		   SUM(CASE
				   WHEN termdate IS NOT NULL AND termdate <= GETDATE() THEN 1
				   END) AS terminations
	FROM hr
	GROUP BY YEAR(hire_date)
) AS subquery;
GO


-- 11. WHAT IS THE TENURE DISTRIBUTION FOR EACH DEPARTMENT
CREATE VIEW vw_avg_tenure_by_dept AS
SELECT department, ROUND(AVG(DATEDIFF(YEAR, hire_date, termdate)), 0) AS avg_tenure
FROM hr
WHERE termdate IS NOT NULL AND termdate <= GETDATE()
GROUP BY department;
GO



-- 12.  termination and hire breakdown gender wise
CREATE VIEW vw_gender_wise_terminations_hires AS
SELECT gender,
	   total_hires,
	   total_terminations,
	   ROUND((total_terminations*100.0/total_hires),2) AS change_percent
FROM (
	SELECT gender,
		   COUNT(*) AS total_hires,
		   SUM(CASE
				   WHEN termdate IS NOT NULL AND termdate <= GETDATE() THEN 1
				   END) AS total_terminations
	FROM hr
	GROUP BY gender
) AS subquery

-- 13.  termination and hire breakdown age wise
CREATE VIEW vw_age_wise_terminations_hires AS
SELECT age,
	   total_hires,
	   total_terminations,
	   ROUND((total_terminations*100.0/total_hires),2) AS change_percent
FROM (
	SELECT age,
		   COUNT(*) AS total_hires,
		   SUM(CASE
				   WHEN termdate IS NOT NULL AND termdate <= GETDATE() THEN 1
				   END) AS total_terminations
	FROM hr
	GROUP BY age
) AS subquery

-- 14.  termination and hire breakdown race wise
CREATE VIEW vw_race_wise_terminations_hires AS
SELECT race,
	   total_hires,
	   total_terminations,
	   ROUND((total_terminations*100.0/total_hires),2) AS termination_rate
FROM (
	SELECT race,
		   COUNT(*) AS total_hires,
		   SUM(CASE
				   WHEN termdate IS NOT NULL AND termdate <= GETDATE() THEN 1
				   END) AS total_terminations
	FROM hr
	GROUP BY race
) AS subquery
