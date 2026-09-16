BULK INSERT hr
FROM 'C:\Users\Admin\Downloads\Human Resources.csv'
WITH(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);


-- CHANGE DATA FORMAT AND CORRECTION OF birthdate

UPDATE hr
SET birthdate = CASE 
					WHEN birthdate LIKE '%/%' THEN CONVERT(date, birthdate, 101)
					WHEN birthdate LIKE '%-%' THEN CONVERT(date, birthdate, 110)
					ELSE NULL
				END

ALTER TABLE hr
ALTER COLUMN birthdate DATE;

--CHANGE DATA FORMAT AND CORRECTION OF hiredate

UPDATE hr
SET hire_date = CASE 
					WHEN hire_date LIKE '%/%' THEN CONVERT(date, hire_date, 101)
					WHEN hire_date LIKE '%-%' THEN CONVERT(date, hire_date, 110)
					ELSE NULL
				END

ALTER TABLE hr
ALTER COLUMN hire_date DATE;



ALTER TABLE hr
ALTER COLUMN termdate NVARCHAR(100) NULL



UPDATE  hr
SET termdate =
CASE 
	WHEN TRIM(termdate) LIKE '%UTC' THEN CAST(REPLACE(TRIM(termdate),'UTC','') AS datetime2)
	ELSE NULL -- still-employed / no valid termination timestamp
	END

ALTER TABLE hr
ALTER COLUMN termdate datetime2


-- CREATING AGE COLOUMN
ALTER TABLE hr
ADD age int

UPDATE hr
SET age = DATEDIFF(YEAR, birthdate, GETDATE()) - 
    CASE 
        WHEN MONTH(birthdate) > MONTH(GETDATE()) 
             OR (MONTH(birthdate) = MONTH(GETDATE()) AND DAY(birthdate) > DAY(GETDATE()))
        THEN 1 
        ELSE 0 
    END;
