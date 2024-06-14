create database cs1;
use cs1;

CREATE TABLE sales (
 customer_id VARCHAR(1) foreign key,
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', 1),
  ('A', '2021-01-01', 2),
  ('A', '2021-01-07', 2),
  ('A', '2021-01-10', 3),
  ('A', '2021-01-11', 3),
  ('A', '2021-01-11', 3),
  ('B', '2021-01-01', 2),
  ('B', '2021-01-02', 2),
  ('B', '2021-01-04', 1),
  ('B', '2021-01-11', 1),
  ('B', '2021-01-16', 3),
  ('B', '2021-02-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-07', 3);
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  (1, 'sushi', 10),
  (2, 'curry', 15),
  (3, 'ramen', 12);
  
CREATE TABLE members (
  customer_id VARCHAR(1) primary key,
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');  
  
 select * from menu;
 select * from members;
 select * from sales;
# Q1  
select sales.customer_id, sum(menu.price) as total_expense from sales join menu on sales.product_id = menu.product_id group by customer_id;

# Q2 - Note : the question is asked for number of days visited not for number of visits in all 
select sales.customer_id, count(distinct(sales.order_date)) from sales group by sales.customer_id;

# Q3
with cte as 
  (select sales.customer_id, menu.product_name, 
  row_number() over(partition by sales.customer_id 
			        order by sales.order_date) as "Order_Num" 
   from sales join menu on sales.product_id = menu.product_id)
select customer_id, product_name from cte where Order_Num = 1;

# Q4
select m.product_name, count(m.product_id) as Totalsale
from menu m join sales s 
on m.product_id = s.product_id
group by m.product_name  order by Totalsale desc limit 1;

# Q5
WITH item_count AS (
    SELECT s.customer_id, m.product_name,
    COUNT(*) as order_count,
    DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) as rn
    FROM sales s
    JOIN menu m
    ON s.product_id = m.product_id
    GROUP BY s.customer_id, m.product_name
)
SELECT customer_id, product_name
FROM item_count
WHERE rn = 1;

# Q6
with cte as 
(select s.customer_id, mb.join_date, s.order_date, m.product_id, m.product_name, m.price,
row_number() over(partition by s.customer_id
                  order by s.order_date) as ord_no
from sales s join members mb on s.customer_id = mb.customer_id
join menu m on s.product_id  = m.product_id where s.order_date > mb.join_date)
select customer_id, product_name from cte where ord_no = 1;

# Q7
with cte as 
(select s.customer_id, mb.join_date, s.order_date, m.product_id, m.product_name, m.price,
DENSE_RANK() over(partition by s.customer_id
                  order by s.order_date desc) as ord_no
from sales s join members mb on s.customer_id = mb.customer_id
join menu m on s.product_id  = m.product_id where s.order_date < mb.join_date)
select customer_id, product_name from cte where ord_no = 1;

# Q8
select s.customer_id, count(s.product_id) as number_of_orders ,sum(m.price) as total_price
from sales s JOIN menu m on s.product_id = m.product_id
JOIN members mb on s.customer_id = mb.customer_id 
where s.order_date < mb.join_date
group by s.customer_id order by s.customer_id;

# Q9
with cte as
(select s.customer_id, 
CASE
    when m.product_name = 'sushi' then 2 * 10 * m.price
    else 10 * m.price
    end as Member_Points
from sales s JOIN menu m 
ON s.product_id = m.product_id)
select customer_id, sum(Member_Points) as Points from cte group by customer_id;

# Q10
with cte as
(SELECT s.customer_id, mb.join_date, s.order_date, m.product_id, m.product_name, m.price, 
CASE 
     WHEN s.order_date between mb.join_date and date_add(join_date, INTERVAL 8 DAY) THEN m.price*10*2 
     when m.product_name = 'sushi' THEN m.price*10*2
     ELSE m.price*10 
     END as points
from sales s JOIN menu m ON s.product_id = m.product_id JOIN members mb ON s.customer_id = mb.customer_id
where order_date < '2021-02-01')
select customer_id, sum(points) as Total_Points from cte group by customer_id order by customer_id;

# Bonus Question - 1 
 SELECT s.customer_id, s.order_date, m.product_name, m.price, 
 CASE
	when s.order_date >= mb.join_date then 'Y'
	else 'N' 
	END as Member_Status
from sales s JOIN menu m ON s.product_id = m.product_id 
LEFT JOIN members mb ON s.customer_id = mb.customer_id;


# Bonus Question - 2 
with cte as
 ( SELECT s.customer_id, s.order_date, m.product_name, m.price, 
 CASE
	when s.order_date >= mb.join_date then 'Y'
	else 'N' 
	END as Member_Status
from sales s JOIN menu m ON s.product_id = m.product_id 
LEFT JOIN members mb ON s.customer_id = mb.customer_id  ORDER BY s.customer_id, s.order_date, m.price DESC)
SELECT *, 
CASE 
when Member_Status = 'Y' then DENSE_RANK() OVER(partition by customer_id, Member_Status order by order_date)
else null  
END as Ranks from cte



