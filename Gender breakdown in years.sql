Task:
Create a visualisation that providesw a breakdown between the male and female employees working in the company each year, starting from 1990.

Tools: MySQL + Tableau Public

Source: 365 Data Science - SQL and Tableau
relational schema:
[1_5_loading-the-database.pdf](https://github.com/MarieSx/PortfolioProjects/files/7370747/1_5_loading-the-database.pdf)


Steps:

Choice between pie chart and bar chart.
When data shows single year, pie is better
But if want to show M F occupation in several years, then stacked bar chart can shows both occupations and trend.

SQL
-- 1. Check details
SELECT * FROM employees_mod.t_employees;

-- 2. retrieve by years
-- calenar_year | gender | num_of_employee

SELECT 
	YEAR(d.from_date) AS calendar_year,
    e.gender,    
    COUNT(e.emp_no) AS num_of_employees
FROM     
	t_employees e         
	JOIN    
	t_dept_emp d 
    ON d.emp_no = e.emp_no
GROUP BY calendar_year , e.gender 
HAVING calendar_year >= 1990;

-- 2.1 Check duplications
SELECT 
	emp_no, from_date, to_date
FROM 
	t_dept_emp;
SELECT DISTINCT 
	emp_no, from_date, to_date
FROM 
	t_dept_emp;

OUTPUT (LIMIT 7):
1998	M	8929
1990	F	5470
1992	M	8480
1993	F	5623
1999	M	9199
1997	M	8930
1998	F	6030

-- 3. Export to CSV and import to Tableau

Tableau

1. Create Stacked bar chart, find out the chart has obscure insight
![image](https://user-images.githubusercontent.com/89245931/137867508-a0c162fd-8663-4679-8fc9-5c4a7a7e3e27.png)
#Note: it only shows how many employees were hired in certain year. But numbers should be accumulated. 
So, need turn to cumulative graph.
![image](https://user-images.githubusercontent.com/89245931/137868097-161a3b02-89c1-4a57-b264-f624862af58e.png)
Result:
![image](https://user-images.githubusercontent.com/89245931/137868850-7df67576-e0b1-4aba-b048-36d903e77038.png)



2. Adjust features on Marks field to set running total as well, so the number is correct.
![image](https://user-images.githubusercontent.com/89245931/137869178-2ce62ab3-2719-4ef5-b30e-57220268154b.png)

3. Set number of employee to % to show better insight
To set feature in Mark field from running toal to percent of total

4. Organise the graph as bars is not perfectly correspond to the year in x-axis
Mark - Size - Alignment - Centre
and adjust x-axis range to shwo exact year needed

5. Fix problem that % are small as the total number uses the total employees working in a certain year, not each bar.
We need total cumulative number to show increasing trend, but when it comes to gender percentage, we need to calculate by table (down) not table (accross)
Mark - number of employee - Computer Using - table(down)

6. Adjust percentage to have one decimal
![image](https://user-images.githubusercontent.com/89245931/137900839-515601ef-024e-4d47-8b0d-0a3c92b68aac.png)
Clike any area in bar - format - Field - % of total sum - total/default - Numbers - percentage - one decimal
![image](https://user-images.githubusercontent.com/89245931/137900972-8ef16f48-3fbd-4f39-ac4e-c54cb56ae8a7.png)



