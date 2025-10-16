select * from walmart;

select count(distinct branch)
from walmart;


select max(quantity) from walmart;

select min(quantity) from walmart;


--Business problems
--Q1.find different payment method and number of transactions,number of qty sold

select 
payment_method,
count(*) as no_of_transactions,
sum(quantity) as qty_sold
from walmart
group by payment_method;

--Q2.identify the highest rated category in each branch ,displaying the branch ,category ,avg rating

SELECT * FROM (

SELECT 
branch,
category,
AVG(rating) as avg_rating,
RANK() OVER(PARTITION by branch ORDER BY AVG(rating) DESC) as rank
FROM walmart 
 GROUP BY 1,2
 )
 WHERE rank=1;
 
--Q3.identify the busiest day for each branch based on the number of transactions

SELECT  *  from(
select
branch,
COUNT(date) AS no_of_transactions,
TO_CHAR(TO_DATE(date,'DD/MM/YY'),'day') AS day_name,
RANK() OVER(PARTITION BY branch ORDER by count(*) DESC) AS rank
FROM walmart GROUP by 1,3 
ORDER BY 1,2 DESC)
where rank=1;

--Q4.Calculate the total quantity of items sold per payment method.list payment method and total_quantity,number of qty sold


select 
payment_method,
sum(quantity) as no_of_qty_sold
from walmart group by 1 order by 2 desc;


--Q5.determine the average ,minimun rating of products for each city.
--list the city,avg_rating,min_rating,max_rating

select
city,
category,
min(rating) as min_rating,
max(rating) as max_rating
from walmart
group by 1,2
order by 3 desc;


--Q6.Calculate the total profit for each category as(unit_price*quantity*profit_margin)
--list the category and total_profit,ordered from highest to lowest profit

select category,
sum(total*profit_margin) as total_profit
from walmart group by 1
order by 1,2 desc;


--Q7.determine the most common payment method for each branch
--display branch and the prefered_payment_method

with cte as(
select 
branch,
payment_method,
count(*) as total_trans,
rank() over(partition by branch order by count(*) desc) as rank
from walmart group by 1,2 order by 3 desc
)
select * from cte
where rank=1;


--Q8.categories sales into 3 group morning ,afternoon, evening
--find out each of the shift and number of invoices



select 
branch,
case
	when EXTRACT(HOUR FROM (time::time))<12 then 'Morning'
	when EXTRACT(HOUR from (time::time)) between 12 and 17 then 'Afternoon'
	else 'Evening'
End  shift ,
COUNT(*)
from walmart 
group by 1,2 order by 1,3 desc;



--9.identify 5 branch with highest decrease ratio in revenue compare to last year
--(current year 2023 and last year 2022)


--2022 sales


WITH rev_2022 as(
select branch,
extract(year from TO_DATE(date,'DD/MM/YY')) as year,
sum(total) as revenue
from walmart
where extract(year from TO_DATE(date,'DD/MM/YY'))=2022
group by 1,2
),

rev_2023 as(
select branch,
extract(year from TO_DATE(date,'DD/MM/YY')) as year,
sum(total) as revenue
from walmart
where extract(year from TO_DATE(date,'DD/MM/YY'))=2023
group by 1,2
)

select 
rev_2022.branch,
rev_2022.revenue as lastyear_revenue,
rev_2023.revenue as curryear_revenue,
round(
(rev_2022.revenue -rev_2023.revenue)::numeric/
rev_2022.revenue::numeric*100,2)  as ratio
from rev_2022
join rev_2023 on 
rev_2023.branch=rev_2022.branch
where rev_2022.revenue>rev_2023.revenue
order by 4 desc
limit 5;
