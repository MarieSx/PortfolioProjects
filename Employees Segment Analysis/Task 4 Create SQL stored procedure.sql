/*
Task 4:
Create an SQL stored procedure that will allow you to obtain the avrage male and female salary per department within a certain salary range. Let this range be defined by tow values the user can insert when calling the procedure.
Finally, visualise the obtained result-set in Tableau as a double bar chart.

Planning:
the certain salary range should exclue outliers, consult the boss then know that: there have not been many people who have earned less than $50,000 or more than $90,000
So, I decide to exclude < $50,000 and >$90,000 

ADD procedure functions
*/
SQL
-- depart name | gender | avg salary

DROP PROCEDURE IF EXISTS filter_salary;

DELIMITER $$
CREATE PROCEDURE filter_salary (IN p_min_salary FLOAT, IN p_max_salary FLOAT)
BEGIN
SELECT 
    e.gender, d.dept_name, AVG(s.salary) as avg_salary
FROM
    t_salaries s
        JOIN
    t_employees e ON s.emp_no = e.emp_no
        JOIN
    t_dept_emp de ON de.emp_no = e.emp_no
        JOIN
    t_departments d ON d.dept_no = de.dept_no
    WHERE s.salary BETWEEN p_min_salary AND p_max_salary
GROUP BY d.dept_no, e.gender;
END$$

DELIMITER ;

CALL filter_salary(50000, 90000);

OUTPUT (LIMIT 7):

M	Development	62924.4289
M	Sales	72609.2690
F	Marketing	67554.2469
F	Production	61860.7746
M	Production	62978.9139
M	Human Resources	60190.3843
F	Development	61963.6756

/*
Tableau:
1. import then dept Name to column and avg salary to row
2. adjust measure for salary from SUM to AVG to correct vertical unit measured
3. Drag gender to color and !! drag gender to column to make DOUBLE BAR CHART

Finished Viz:
https://public.tableau.com/views/AverageSalaryMFindepartments/Chart4?:language=en-US&publish=yes&:display_count=n&:origin=viz_share_link
*/
