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
SELECT cust_id,
       cust_first_name,
       cust_last_name,
       cust_state_province,
       cust_credit_limit,
       RANK() OVER (PARTITION BY cust_state_province ORDER BY cust_credit_limit DESC) AS state_rank
FROM sh.customers;

--3.Use DENSE_RANK() to find the top 5 credit holders per country.
SELECT *
FROM (
    SELECT cust_id,
           cust_first_name,
           cust_last_name,
           country_id,
           cust_credit_limit,
           DENSE_RANK() OVER (PARTITION BY country_id ORDER BY cust_credit_limit DESC) AS country_rank
    FROM sh.customers
)
WHERE country_rank <= 5
ORDER BY country_id, country_rank;

--4.Divide customers into 4 quartiles based on their credit limit using NTILE(4).
SELECT 
    cust_id,
    cust_first_name,
    cust_last_name,
    cust_credit_limit,
    NTILE(4) OVER (ORDER BY cust_credit_limit DESC) AS credit_quartile
FROM sh.customers

--5.Calculate a running total of credit limits ordered by customer_id.
SELECT 
    cust_id,
    cust_first_name,
    cust_credit_limit,
    SUM(cust_credit_limit) OVER (ORDER BY cust_id) AS running_total
FROM sh.customers;

--6.Show cumulative average credit limit by country.
SELECT 
    cust_id,
    cust_first_name,
    country_id,
    AVG(cust_credit_limit) OVER (PARTITION BY country_id ORDER BY cust_credit_limit) AS average_credit_limit
FROM sh.customers;

--7.Compare each customer’s credit limit to the previous one using LAG().
SELECT
    cust_id,
    cust_credit_limit,
    LAG(cust_credit_limit) OVER (ORDER BY cust_id) AS previous_credit_limit,
    cust_credit_limit - LAG(cust_credit_limit) OVER (ORDER BY cust_id) AS difference
FROM sh.customers;

--8.Show next customer’s credit limit using LEAD().
SELECT
      cust_id,
      cust_first_name,
      cust_credit_limit,
      LEAD (cust_credit_limit) OVER (Order By cust_id) next_credit_limit
from sh.customers;

--9.Display the difference between each customer’s credit limit and the previous one.
select
    cust_id,
    cust_first_name,
    cust_credit_limit,
    LAG(cust_credit_limit) OVER ( Order by cust_id) previous_credit_limit,
    cust_credit_limit - LAG(cust_credit_limit) Over (order by cust_id) difference
 from sh.customers;

--10.For each country, display the first and last credit limit using FIRST_VALUE() and LAST_VALUE().
select
    cust_id,
    cust_first_name,
    cust_credit_limit,
    FIRST_VALUE(cust_credit_limit) OVER (PARTITION BY country_id ORDER BY cust_id) AS first_credit_limit,
    LAST_VALUE(cust_credit_limit) OVER (
        PARTITION BY country_id
        ORDER BY cust_id 
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_credit_limit
FROM sh.customers
ORDER BY
    country_id, cust_id;

--11.Compute percentage rank (PERCENT_RANK()) of customers based on credit limit.
Select
    cust_id,
    cust_first_name,
    cust_credit_limit,
    PERCENT_RANK() OVER (ORDER BY cust_credit_limit) AS percent_rank
FROM sh.customers
ORDER BY cust_credit_limit;

--12.Show each customer’s position in percentile (CUME_DIST() function).
Select
      cust_id,
      cust_first_name,
      cust_credit_limit,
      CUME_DIST () over (Order by cust_credit_limit) AS CUME_DIST
from sh.customers;

--13.Display the difference between the maximum and current credit limit for each customer.
Select
    cust_id,
    cust_first_name,
    cust_credit_limit,
    MAX(cust_credit_limit) OVER () - cust_credit_limit AS diff_max
from sh.customers

--14.Rank income levels by their average credit limit.
Select
      cust_id,
      cust_first_name,
      cust_credit_limit,
      avg(cust_credit_limit) over (order by cust_id) AS average_credit_limit
from sh.customers

--15.Calculate the average credit limit over the last 10 customers (sliding window).

--16.For each state, calculate the cumulative total of credit limits ordered by city.
Select
      cust_id,
      cust_first_name,
      cust_credit_limit,
      cust_city,
      Sum(cust_credit_limit) over (PARTITION by cust_city  order by cust_credit_limit) AS total_credit
from sh.customers;

--17.Find customers whose credit limit equals the median credit limit (use PERCENTILE_CONT(0.5)).

--18.Display the highest 3 credit holders per state using ROW_NUMBER() and PARTITION BY.
SELECT *
FROM (
    SELECT
        cust_id,
        cust_first_name,
        cust_state_province,
        cust_credit_limit,
        ROW_NUMBER() OVER (
            PARTITION BY cust_state_province
            ORDER BY cust_credit_limit DESC
        ) AS rn
    FROM sh.customers
) sub
WHERE rn <= 3;

--19.Identify customers whose credit limit increased compared to previous row (using LAG).
SELECT *
FROM (
    SELECT
        cust_id,
        cust_first_name,
        cust_credit_limit,
        LAG(cust_credit_limit) OVER (ORDER BY cust_id) AS previous_credit_limit
    FROM customers
) sub
WHERE cust_credit_limit > previous_credit_limit;

--20.Calculate moving average of credit limits with a window of 3.
SELECT
    cust_id,
    cust_first_name,
    cust_credit_limit,
    ROUND(
        AVG(cust_credit_limit) OVER (
            ORDER BY cust_id
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2
    ) AS moving_avg_3
FROM sh.customers
ORDER BY cust_id; 

--21.Show cumulative percentage of total credit limit per country.
SELECT
    country_id,
    cust_id,
    cust_first_name,
    cust_credit_limit,
    SUM(cust_credit_limit) OVER (
        PARTITION BY country_id
        ORDER BY cust_credit_limit
        ROWS UNBOUNDED PRECEDING
    ) AS cumulative_credit,
    ROUND(
        SUM(cust_credit_limit) OVER (
            PARTITION BY country_id
            ORDER BY cust_credit_limit
            ROWS UNBOUNDED PRECEDING
        )
        / SUM(cust_credit_limit) OVER (PARTITION BY country_id) * 100,
        2
    ) AS cumulative_percentage
FROM
    sh.customers
ORDER BY
    country_id,
    cust_credit_limit;

--22.Rank customers by age (derived from CUST_YEAR_OF_BIRTH).
SELECT
    cust_id,
    cust_first_name,
    cust_year_of_birth,
    EXTRACT(YEAR FROM SYSDATE) - cust_year_of_birth AS age,
    RANK() OVER (ORDER BY (EXTRACT(YEAR FROM SYSDATE) - cust_year_of_birth) DESC) AS age_rank
FROM sh.customers
ORDER BY age_rank;

--23.Calculate difference in age between current and previous customer in the same state.
SELECT
    cust_id,
    cust_first_name,
    cust_state_province,
    EXTRACT(YEAR FROM SYSDATE) - cust_year_of_birth AS age,
    (EXTRACT(YEAR FROM SYSDATE) - cust_year_of_birth)
      - LAG(EXTRACT(YEAR FROM SYSDATE) - cust_year_of_birth)
        OVER (PARTITION BY cust_state_province ORDER BY cust_id) AS age_difference
FROM sh.customers
ORDER BY cust_state_province, cust_id;

--24.Use RANK() and DENSE_RANK() to show how ties are treated differently.
SELECT
    cust_id,
    cust_first_name,
    cust_credit_limit,
    RANK() OVER (ORDER BY cust_credit_limit DESC) AS rank_value,
    DENSE_RANK() OVER (ORDER BY cust_credit_limit DESC) AS dense_rank_value
FROM
    sh.customers
ORDER BY
    cust_credit_limit DESC;

--25.Compare each state’s average credit limit with country average using window partition.
SELECT
    country_id,
    cust_state_province,
    ROUND(AVG(cust_credit_limit) OVER (PARTITION BY cust_state_province), 2) AS state_avg_credit,
    ROUND(AVG(cust_credit_limit) OVER (PARTITION BY country_id), 2) AS country_id_avg_credit,
    ROUND(
        AVG(cust_credit_limit) OVER (PARTITION BY cust_state_province)
        - AVG(cust_credit_limit) OVER (PARTITION BY country_id),
        2
    ) AS diff_from_country_id_avg
FROM sh.customers
ORDER BY
    country_id,
    cust_state_province;

--26.Show total credit per state and also its rank within each country.
SELECT
    country_id,
    cust_state_province,
    SUM(cust_credit_limit) AS total_credit,
    RANK() OVER (PARTITION BY country_id ORDER BY SUM(cust_credit_limit) DESC) AS state_rank
FROM sh.customers
GROUP BY
    country_id,
    cust_state_province
ORDER BY
    country_id,
    state_rank;

--27.Find customers whose credit limit is above the 90th percentile of their income level.
SELECT *
FROM (
    SELECT
        cust_id,
        cust_first_name,
        cust_income_level,
        cust_credit_limit,
        PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY cust_credit_limit) 
            OVER (PARTITION BY cust_income_level) AS pct_90_credit
    FROM
        sh.customers
) sub
WHERE cust_credit_limit > pct_90_credit
ORDER BY cust_income_level, cust_credit_limit DESC;

--28.Display top 3 and bottom 3 customers per country by credit limit.SELECT *
SELECT *
FROM (
    SELECT
        cust_id,
        cust_first_name,
        country_id,
        cust_credit_limit,
        ROW_NUMBER() OVER (PARTITION BY country_id ORDER BY cust_credit_limit DESC) AS rn_top,
        ROW_NUMBER() OVER (PARTITION BY country_id ORDER BY cust_credit_limit ASC) AS rn_bottom
    FROM sh.customers
) sub
WHERE rn_top <= 3 OR rn_bottom <= 3
ORDER BY country_id, rn_top;

--29.Calculate rolling sum of 5 customers’ credit limit within each country.
SELECT
    cust_id,
    cust_first_name,
    country_id,
    cust_credit_limit,
    SUM(cust_credit_limit) OVER (
        PARTITION BY country_id
        ORDER BY cust_id
        ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    ) AS rolling_sum_5
FROM sh.customers
ORDER BY country_id, cust_id;

--30.For each marital status, display the most and least wealthy customers using analytical functions.
SELECT *
FROM (
    SELECT
        cust_id,
        cust_first_name,
        cust_marital_status,
        cust_credit_limit,
        ROW_NUMBER() OVER (
            PARTITION BY cust_marital_status
            ORDER BY cust_credit_limit DESC
        ) AS rn_most,
        ROW_NUMBER() OVER (
            PARTITION BY cust_marital_status
            ORDER BY cust_credit_limit ASC
        ) AS rn_least
    FROM sh.customers
) sub
WHERE rn_most = 1 OR rn_least = 1
ORDER BY cust_marital_status;
