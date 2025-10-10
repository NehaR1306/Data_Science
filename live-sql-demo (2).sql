--1.Find the total, average, minimum, and maximum credit limit of all customers.
select cust_id , avg(cust_credit_limit) , min(cust_credit_limit),max(cust_credit_limit) from sh.customers group by cust_id

--2.Count the number of customers in each income level.
select cust_income_level, count(*)
from sh.CUSTOMERS
group by cust_income_level

--3.Show total credit limit by state and country.
select sum(cust_credit_limit) AS total_credit_limit , cust_state_province , country_id from sh.customers group by cust_credit_limit , cust_state_province , country_id

--4.Display average credit limit for each marital status and gender combination.
select cust_marital_status , cust_gender , avg(cust_credit_limit) AS average_credit_limit from sh.customers group by cust_gender , cust_marital_status , cust_credit_limit

--5.Find the top 3 states with the highest average credit limit.
select cust_state_province , 
avg(cust_credit_limit) AS average_credit_limit
from sh.customers
group by cust_state_province 
order by average_credit_limit DESC
fetch first 3 rows only;

--6.Find the country with the maximum total customer credit limit.
select country_id , max(cust_credit_limit) AS Maximum_credit_limit 
from sh.customers 
group by country_id

--7.Show the number of customers whose credit limit exceeds their state average.
SELECT COUNT(*)
FROM sh.customers c
WHERE cust_credit_limit > (
    SELECT AVG(cust_credit_limit)
    FROM sh.customers
    WHERE cust_state_province = c.cust_state_province
)

--8.Calculate total and average credit limit for customers born after 1980.
SELECT cust_year_of_birth,
       AVG(cust_credit_limit) AS average_credit_limit
FROM sh.customers
WHERE cust_year_of_birth > 1980
GROUP BY cust_year_of_birth

--9.Find states having more than 50 customers.
SELECT cust_state_province,
       COUNT(*) AS number_of_customers
FROM sh.customers
GROUP BY cust_state_province
HAVING COUNT(*) > 50;

--10.List countries where the average credit limit is higher than the global average.
SELECT country_id,
       AVG(cust_credit_limit) AS avg_credit_limit
FROM sh.customers
GROUP BY country_id
HAVING AVG(cust_credit_limit) > (
    SELECT AVG(cust_credit_limit)
    FROM sh.customers
);

--11.Calculate the variance and standard deviation of customer credit limits by country.
SELECT country_id,
       VAR_SAMP(cust_credit_limit) AS credit_limit_variance,
       STDDEV_SAMP(cust_credit_limit) AS credit_limit_stddev
FROM sh.customers
GROUP BY country_id;

--12.Find the state with the smallest range (max–min) in credit limits.
SELECT cust_state_province,
       MAX(cust_credit_limit) - MIN(cust_credit_limit) AS credit_limit_range
FROM sh.customers
GROUP BY cust_state_province
ORDER BY credit_limit_range ASC
FETCH FIRST 1 ROW ONLY;

--13.Show the total number of customers per income level and the percentage contribution of each.
SELECT cust_income_level,
       COUNT(*) AS total_customers,
       ROUND((COUNT(*) * 100.0) / (SELECT COUNT(*) FROM sh.customers), 2) AS percentage
FROM sh.customers
GROUP BY cust_income_level;

--14.For each income level, find how many customers have NULL credit limits.
SELECT cust_income_level,
       COUNT(*) AS null_credit_count
FROM sh.customers
WHERE cust_credit_limit IS NULL
GROUP BY cust_income_level;

--15.Display countries where the sum of credit limits exceeds 10 million.
SELECT country_id,
       SUM(cust_credit_limit) AS total_credit_limit
FROM sh.customers
GROUP BY country_id
HAVING SUM(cust_credit_limit) > 10000000;

--16.Find the state that contributes the highest total credit limit to its country.
SELECT country_id, cust_state_province_id, SUM(cust_credit_limit) AS total_credit
FROM sh.customers
GROUP BY country_id, cust_state_province_id
HAVING SUM(cust_credit_limit) = (
    SELECT MAX(SUM(cust_credit_limit))
    FROM sh.customers
    WHERE country_id = sh.customers.country_id
    GROUP BY cust_state_province_id
)

--17.Show total credit limit per year of birth, sorted by total descending.
SELECT cust_year_of_birth,
       SUM(cust_credit_limit) AS total_credit_limit
FROM sh.customers
GROUP BY cust_year_of_birth
ORDER BY total_credit_limit DESC;

--18.Identify customers who hold the maximum credit limit in their respective country.
SELECT cust_id,
       country_id,
       cust_credit_limit
FROM sh.customers c1
WHERE cust_credit_limit = (
    SELECT MAX(cust_credit_limit)
    FROM sh.customers c2
    WHERE c2.country_id = c1.country_id
);

--19.Show the difference between maximum and average credit limit per country.
SELECT country_id,
       MAX(cust_credit_limit) - AVG(cust_credit_limit) AS max_avg_difference
FROM sh.customers
GROUP BY country_id;

--20.Display the overall rank of each state based on its total credit limit (using GROUP BY + analytic rank).
SELECT cust_state_province,
       SUM(cust_credit_limit) AS total_credit_limit,
       RANK() OVER (ORDER BY SUM(cust_credit_limit) DESC) AS state_rank
FROM sh.customers
GROUP BY cust_state_province
ORDER BY state_rank;

-----Analytical / Window Functions (30 Questions)

--1.Assign row numbers to customers ordered by credit limit descending.
SELECT cust_id,
       cust_first_name,
       cust_last_name,
       cust_credit_limit,
       ROW_NUMBER() OVER (ORDER BY cust_credit_limit DESC) AS rn
FROM sh.customers;

--2.Rank customers within each state by credit limit.
select cust_first_name
cust_last_name,
cust_state_province
cust_credit_limit
rank
--3.Use DENSE_RANK() to find the top 5 credit holders per country.
--4.Divide customers into 4 quartiles based on their credit limit using NTILE(4).
--5.Calculate a running total of credit limits ordered by customer_id.