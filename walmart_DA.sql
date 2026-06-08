select * from walmart;
--
select count (*) from walmart;
--

select distinct payment_method from walmart;
--
select payment_method, count(*) from walmart group by payment_method;
--
--here 2 column names are in capital and in sql all r bydefault small so we r getting problem so lets drop this all ;}

select * from walmart;

---
SELECT COUNT (*) FROM walmart;



----
SELECT COUNT (DISTINCT branch) FROM walmart;
----
select max(quantity) from walmart;

-- 
select min(quantity) from walmart;

--------------BUISNESS PROBLEMS-------------


--Q1
--find different payments methods,number of qty sold and number of transtactions

select 
payment_method,
count(*) as no_of_pymts,
sum(quantity) as no_qty_sold
from walmart 
group by payment_method;
------------



--Q2
--identify the highest rated category in each branch display the  branch,category and avg rating

select * from walmart;
---
select branch,
category,
avg(rating) as avg_rating,
	RANK() over(partition by branch order by avg(rating) desc) as rank
from walmart group by 1,2;

-----------------


--highest rating from each branch

select * from(
select branch,
category,
avg(rating) as avg_rating,
	RANK() over(partition by branch order by avg(rating) desc) as rank
from walmart group by 1,2

)
where rank = 1;

----------


--Q3
--identify busiest day from each branch from the no of transtacions
--1st we have converted the date to the day---
select 
date,
to_char(to_date(date,'DD/MM/YY'), 'day') as day_nama
 from walmart;
------

select * from
(select 
branch,
to_char(to_date(date,'DD/MM/YY'), 'day') as day_nama,
count (*) as no_transactions,
	rank() over(partition by branch order by count(*) desc )as rank
 from walmart
 group by 1,2) where
 rank=1;
	
 
------

--Q4
---calculatting total qty of items sold per payment method list the payment method and qty---

select payment_method,
count (*) as no_of_payments,
sum(quantity) as no_qty_sold
from walmart
group by payment_method;

------------


--Q5
----determine avg,max,min rating of category for each city,
--list the city,avg_rating,min_rating,max_rating

select 
city,
category,
min(rating) as min_rating,
max(rating) as max_rating,
avg(rating) as avg_rating
from walmart
group by 1,2;

------------


--Q6
----determine avg,max,min rating of category for littele elm city,
--list the city,avg_rating,min_rating,max_rating


select * from (select 
city,
category,
min(rating) as min_rating,
max(rating) as max_rating,
avg(rating) as avg_rating
from walmart
group by 1,2)
where
city ='Little Elm';


----------

--Q7
--calculate total profit for each categaory by considering  total_profit as 
--(unit_price*qty*profit_margin) list category and total_profit,ordered from highest to lowest profit.


select
category,
sum(tot_qty) as total_revene,
sum(tot_qty*profit_margin) as profit
from walmart
group by 1;


--Q8
--determine the most common payment method for each branch. display branch and preffred_payment_method


select
	branch,
	payment_method,
	count(*) as total_transaction,
	rank() over(partition by branch order by count(*) desc) as  rank
from walmart
group by 1,2;




--- we will work with cte which is knnd oftemprorary table\

with cte
as (
select
	branch,
	payment_method,
	count(*) as total_transaction,
	rank() over(partition by branch order by count(*) desc) as  rank
from walmart
group by 1,2
)
select * from cte where rank=1;



---Q9
---categorise salesinto 3 group morning,afternoon,evining
---findout each of shift and number of invoices

-- select *,
-- case
-- 	when extract (hour from (time::time)) < 12 then 'morning'
-- 	when extract(hour from(time::time)) between 12 and 17 then 'afternoon'
-- 	else 'evining'
-- 	end day_time
-- from walmart
-- group by 1; 

-----
select
case
	when extract(hour from(time::time)) < 12 then'morning'
	when extract(hour from(time::time)) between 12 and 17 then 'afternoon'
	else'evinig'
	end day_time,
count(*)
from walmart
group by 1;


--for brnachwise-----------

select
branch,
case
	when extract(hour from(time::time)) < 12 then'morning'
	when extract(hour from(time::time)) between 12 and 17 then 'afternoon'
	else'evening'
	end day_time,
count(*)
from walmart
group by 1,2;



---Q10
---identify the branch with highest decrease ratio in revenue
---compared to last year(current yr 2023 and last year 2022)


--rdr=last_rev-cr_rev/last_rev*100

select 
branch,
sum(tot_qty) as revenue
from walmart
group by 1;

select * from walmart;
---------------------lets convert date(text) into date
select
To_Date(date,'DD/MM/YY') as formtd_dte
from walmart;
-----------------------

select *,
Extract (year from To_Date(date,'DD/MM/YY')) as formtd_dte
from walmart;
--------------------------------------2022 sales--------

with rev_2022
as
(select
branch,
sum(tot_qty) as revenue
from walmart
where Extract (year from To_Date(date,'DD/MM/YY')) = 2022
group by 1
),
rev_2023 as
(select
branch,
sum(tot_qty) as revenue
from walmart
where Extract (year from To_Date(date,'DD/MM/YY')) = 2023
group by 1
)

select 
ls.branch,
ls.revenue as last_year_rev,
cs.revenue as current_year_rev_2023


from rev_2022 as ls
join
rev_2023 as cs
on 
ls.branch = cs.branch;


-----------------for current year revenue drop,--------------



with rev_2022
as
(select
branch,
sum(tot_qty) as revenue
from walmart
where Extract (year from To_Date(date,'DD/MM/YY')) = 2022
group by 1
),
rev_2023 as
(select
branch,
sum(tot_qty) as revenue
from walmart
where Extract (year from To_Date(date,'DD/MM/YY')) = 2023
group by 1
)

select 
ls.branch,
ls.revenue as last_year_rev,
cs.revenue as current_year_rev_2023


from rev_2022 as ls
join
rev_2023 as cs
on 
ls.branch = cs.branch
where
ls.revenue>cs.revenue;


-----------------revenue ratio we wil do-------------


with rev_2022
as
(select
branch,
sum(tot_qty) as revenue
from walmart
where Extract (year from To_Date(date,'DD/MM/YY')) = 2022
group by 1
),
rev_2023 as
(select
branch,
sum(tot_qty) as revenue
from walmart
where Extract (year from To_Date(date,'DD/MM/YY')) = 2023
group by 1
)

select 
ls.branch,
ls.revenue as last_year_rev,
cs.revenue as current_year_rev_2023,

(ls.revenue - cs.revenue):: numeric /ls.revenue::numeric*100 as rev_dec_ratio

from rev_2022 as ls
join
rev_2023 as cs
on 
ls.branch = cs.branch
where
ls.revenue>cs.revenue
order by 4 desc
limit 5;








	