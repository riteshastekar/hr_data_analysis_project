-- 1.WHAT IS THE GENDER BREAKDOWN OF EMPLOYEE IN THE COMPANY
SELECT gender,COUNT(*) AS count_gen
FROM hr
WHERE termdate IS NULL
GROUP BY gender 
ORDER BY count_gen DESC

-- 2.WHAT IS THE RACE BREAKDOWN OF THE EMPLOYEE IN THE COMPANY
SELECT race,COUNT(*) AS count_race
FROM hr
WHERE termdate IS NULL
GROUP BY race 
ORDER BY count_race DESC

-- 3.WHAT IS THE AGE DISTRIBUTION OF EMPLOYEES IN COMPANY
SELECT age_group,COUNT(*) FROM
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
ORDER BY age_group

-- 4. HOW MANY EMPLOYEES WORK AT HQ VS REMOTE
SELECT location,COUNT(*) FROM hr
WHERE termdate IS NULL
GROUP BY location


--5. WHAT IS AVERAGE LENGTH OF THE EMPLOYMENT WHO HAVE BEEN TERMINATED
SELECT ROUND(AVG(DATEDIFF(YEAR,hire_date,termdate)),0) AS length_of_employment FROM hr
WHERE termdate IS NOT NULL AND termdate <= GETDATE()


--6.HOW DOES GENDER DISTRIBUTION VARY ACROSS dept. and jobtitle
SELECT department,jobtitle,gender,COUNT(*) AS counts 
FROM hr
WHERE termdate IS NULL
GROUP BY department,jobtitle,gender
ORDER BY department,jobtitle,gender


-- 7. WHAT IS THE DISTRIBUTION OF JOBTITLE ACROSS THE COMPANY

SELECT jobtitle,COUNT(*) AS counts 
FROM hr
WHERE termdate IS NULL
GROUP BY jobtitle
ORDER BY counts DESC

-- 8. WHICH DEPT HAS THE HIGHER TURNOVER/TERMINATION RATE
SELECT  department,
		COUNT(*) AS Total_count,
		COUNT(CASE
				   WHEN termdate IS NOT NULL AND termdate <= GETDATE() THEN 1 
				   END)AS terminated_count,
		ROUND(COUNT(CASE 
						 WHEN termdate IS NOT NULL AND termdate <= GETDATE() THEN 1 
						 END)*100.0/COUNT(*),2) AS termination_rate
FROM hr
GROUP BY department
ORDER BY termination_rate DESC

-- 9. WHAT IS THE DISTRIBUTION OF EMPLOYEES ACROSS LOCATION_STATE
SELECT location_state,COUNT(*) AS counts
FROM hr
WHERE termdate IS NULL
GROUP BY location_state
-- BY CITY
SELECT location_city,COUNT(*) AS counts
FROM hr
WHERE termdate IS NULL
GROUP BY location_city

-- 10. HOW HAS THE COMPANY'S EMPLOYEE COUNT CHANGED OVER TIME BASED ON hire and termination date

SELECT years,
	   hires,
	   terminations,
	   hires-terminations AS net_change,
	   (terminations*100.0 /hires)AS change_percent
FROM (SELECT YEAR(hire_date) AS years,
			 COUNT(*) AS hires,
			 SUM(CASE
				   WHEN termdate IS NOT NULL AND termdate <= GETDATE() THEN 1 
				   END)AS terminations
			FROM hr
			GROUP BY YEAR(hire_date)
		)AS subquery
ORDER BY years;
	
--11.WHAT IS THE TENURE DISTRIBUTION FOR EACH DEPARTMENT
SELECT department,ROUND(AVG(DATEDIFF(YEAR,hire_date,termdate)),0) AS avg_tenure
FROM hr
WHERE termdate IS NOT NULL AND termdate <= GETDATE()
GROUP BY department
ORDER BY avg_tenure
