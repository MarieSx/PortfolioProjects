/* 
Task 3:
Compare the average salary of female vs male employees in the entire company until year 2002, and add a filter allowing to see that per each deparment.

*/

SQL
-- Planning
-- gender | depart name | avg salary | year

SELECT 
    e.gender,
    d.dept_name,
    ROUND(AVG(s.salary), 2) AS salary,
    YEAR(s.from_date) AS calendar_year
FROM
    t_salaries s
        JOIN
    t_employees e ON s.emp_no = e.emp_no
        JOIN
    t_dept_emp de ON de.emp_no = e.emp_no
        JOIN
    t_departments d ON d.dept_no = de.dept_no
GROUP BY d.dept_no , e.gender , calendar_year
HAVING calendar_year <= 2002
ORDER BY d.dept_no;

OUTPUT (LIMIT 7):
M	Marketing	58895.85	1990
M	Marketing	59232.75	1991
M	Marketing	59743.08	1992
M	Marketing	60436.85	1993
M	Marketing	64547.55	1994
M	Marketing	65377.05	1995
M	Marketing	66467.56	1996

/*
Tableau:
1. Upload csv to sheet 3
2. Calendar year to Column and avg salary to row (notice: change sum to avg or the vertical unit seems wrong)
3. add gender to detail and color in Mark field
4. Click department name and choose show filter
5. Random choose one number and compare with sql output to double check its correction

Finished Viz Link:
https://public.tableau.com/views/AvgSalaryacrossdepartmentsMF/Chart3?:language=en-US&publish=yes&:display_count=n&:origin=viz_share_link
