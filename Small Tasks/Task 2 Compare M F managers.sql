/*
Task 2:
Compare the number of male managers to the number of female managers from different departments for each year. Starting from 1990.

Tools: MySQL + Tableau Public

Source: 365 Data Science - SQL and Tableau
relational schema:
[1_5_loading-the-database.pdf](https://github.com/MarieSx/PortfolioProjects/files/7370747/1_5_loading-the-database.pdf)


!! Consider to add active column to show whether an employee is work as a manager (0/1)
![image](https://user-images.githubusercontent.com/89245931/137922438-cdf35d49-178b-49d9-a5e9-a8bd9053b6e2.png)
planning process:
https://user-images.githubusercontent.com/89245931/137925943-4eaf392d-12f2-4e27-92af-217d22842d87.png

*/ 

SQL

-- Planning
-- t_dept_manager dm; t_employees ee; t_departments d;
-- d.dept_name | ee.gender | dm.from_date | dm.to_date | e.calendar_year | active

-- temp table e: year(ee.hire_date) as calendar_year
-- create active condition: from_date <= calendar_year <= to_date --> 1 else 0 as active
-- table e need to select from first and cross join dm to make sure every row has an active value

SELECT 
	d.dept_name,
    ee.gender,
    dm.from_date,
    dm.to_date,
    e.calendar_year,
		CASE WHEN YEAR(dm.from_date) <= e.calendar_year AND e.calendar_year <= YEAR(dm.to_date) THEN 1
        ELSE 0 END 
	AS active
FROM 
	(SELECT YEAR(ee.hire_date) AS calendar_year
    FROM t_employees AS ee
    GROUP BY calendar_year) AS e
		CROSS JOIN
	t_dept_manager dm
		JOIN
	t_departments d ON dm.dept_no = d.dept_no
		JOIN
	t_employees ee ON ee.emp_no = dm.emp_no
ORDER BY dm.dept_no, calendar_year

OUTPUT (LIMIT 7):
Marketing	F	1998-05-29	2000-05-27	1990	0
Marketing	M	1999-05-29	2000-05-27	1990	0
Marketing	M	1995-12-30	1998-12-29	1990	0
Marketing	M	1997-04-09	9999-01-01	1990	0
Marketing	M	1991-12-31	1997-12-29	1990	0
Marketing	F	1993-08-02	1998-08-01	1990	0
Marketing	M	1993-12-30	2000-12-28	1990	0

/*
Tableau

1. need to compare active male employees & active female employess for each year
2. year - horizontal; active - vertical
3. add gender to mark with detail and color feature
4. change to area chart.
5. Create same type of chart for each department ( right click dept name --> show filter)
![image](https://user-images.githubusercontent.com/89245931/137933051-30247f65-bb39-42ac-9030-c64d8cf39e6c.png)

FINISH VIZ:
https://public.tableau.com/views/Activemaleemployeesactivefemaleemployessforeachyear/Chart2?:language=en-US&publish=yes&:display_count=n&:origin=viz_share_link



