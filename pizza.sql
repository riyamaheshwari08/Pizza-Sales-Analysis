-- KPI’s REQUIREMENT 

-- TOTAL REVENUE
SELECT sum(total_order_price) AS  "Total Revenue" FROM orders;

-- AVERAGE ORDER VALUE
SELECT AVG(total_order_price) AS "Average Value" FROM orders;

-- TOTAL PIZZA SOLD
SELECT sum(quantity) AS "TOTAL PIZZA SOLD" from order_pizza;

-- TOTAL ORDERS
SELECT count(order_id) AS "TOTAL ORDERS" FROM orders;

-- AVERAGE PIZZA PRICE
SELECT AVG(unit_price) AS "average pizza price" from pizaa;

-- AVERAGE PIZZA PER ORDER
SELECT SUM(total_order_quantity)/count(*) as "average pizza per order" from orders;

-- TOP THREE PEAK HOUR 
SELECT EXTRACT(HOUR FROM order_time) AS hour_of_day,
COUNT(order_id) as "total_orders" from orders
group by hour_of_day
order by total_orders desc limit 3;

-- SECTOR WISE ANALYSIS

-- 1. Sales Performance Analysis

-- a. What is the average unit price and revenue of pizza across different categories?
SELECT p.pizza_category,avg(unit_price) as "average_unit_price",sum(quantity*unit_price) as "total_revenue" from order_pizza op
join orders o
on
o.order_id=op.order_id
join pizaa p on
p.pizza_name_id=op.pizza_name_id
group by p.pizza_category
order by total_revenue desc ;

-- b. What is the average unit price and revenue of pizza across different sizes?
SELECT p.pizza_size,avg(unit_price) as "average_unit_price",sum(quantity*unit_price) as "total_revenue" from order_pizza op
join orders o on
o.order_id=op.order_id
join pizaa p on
p.pizza_name_id=op.pizza_name_id
group by p.pizza_size
order by total_revenue desc;

-- c. What is the average unit price and revenue of most sold 3 pizzas?
SELECT p.pizza_name,avg(unit_price) as "average_unit_price",sum(quantity*unit_price) as "total_revenue" from order_pizza op
join orders o on
o.order_id=op.order_id
join pizaa p on
p.pizza_name_id=op.pizza_name_id
group by p.pizza_name
order by total_revenue desc limit 3;

-- 2. Seasonal Analysis

-- a. Which days of the week have the highest number of orders
SELECT DAYNAME(STR_TO_DATE(order_date, '%d-%m-%y')) AS day_of_week, count(*) AS total_orders,sum(total_order_price)  FROM orders
GROUP BY day_of_week
ORDER BY total_orders DESC;
    
-- b. At what time do most orders occur
select time_format(order_time,'%h:%i') as delivery_time ,count(*) as delivery from orders
group by delivery_time
order by delivery desc
limit 5;

-- c.Which month has the highest revenue
select monthname(STR_TO_DATE(order_date,'%d-%m-%y')) as month_name,sum(total_order_price) as month_revenue from orders
group by month_name
order by month_revenue desc
limit 5;

-- d. Which season has the highest revenue
select
  case 
    when month(STR_TO_DATE(order_date,'%d-%m-%y')) in (3,4,5) then 'Spring'
    when month(STR_TO_DATE(order_date,'%d-%m-%y')) in (6,7,8) then 'Summer'
    when month(STR_TO_DATE(order_date,'%d-%m-%y')) in (9,10,11) then 'Fall'
    else 'Winter'
    end as Season,sum(total_order_price) as total_revenue
    from orders
    group by season
    order by total_revenue desc;
    
-- 3. Customer Behaviour Analysis

create view  pizza_sales_view as
SELECT t1.order_id,t3.pizza_name_id,order_date,order_time,unit_price,pizza_size,
       pizza_category,ingridients,pizza_name,quantity
from order_pizza t1
join orders t2 on t1.order_id = t2.order_id
join pizaa  t3 on t1.pizza_name_id = t3.pizza_name_id;

-- 1.Which is the favorite pizza of customers (most ordered Pizza) 
select pizza_name,pizza_size,count(order_id) as total_pizza from pizza_sales_view
group by pizza_name,pizza_size
order by total_pizza desc limit 1;

-- 2.  Which Pizza name is preferred by customers 
select pizza_name,count(order_id) as total_pizza from pizza_sales_view
group by pizza_name
order by total_pizza desc limit 5;

-- 3. Which Pizza size is preferred by customers 
select pizza_size,count(order_id) as total_pizza from pizza_sales_view
group by pizza_size
order by total_pizza desc;

-- 4. Which Pizza category is preferred by customers?
select pizza_category,count(order_id) as total_pizza from pizza_sales_view
group by pizza_category
order by total_pizza desc;

-- 4. Pizza Analysis

-- 1. The pizza with the least price and highest price
SELECT pizza_name,unit_price,
CASE 
WHEN unit_price = (SELECT MIN(unit_price) FROM pizaa) THEN 'Min'
WHEN unit_price = (SELECT MAX(unit_price) FROM pizaa) THEN 'Max'
ELSE 'Other'
END AS min_max
FROM pizaa
WHERE unit_price IN (SELECT MIN(unit_price) FROM pizaa UNION SELECT MAX(unit_price) FROM pizaa);

-- 2. Number of pizzas per category
select pizza_category,count(*) as count from pizaa
group by pizza_category
order by count desc ;

-- 3. Number of pizzas per size
select pizza_size,count(*) as count from pizaa
group by pizza_size
order by count desc ;

-- 4.Pizzas with more than one category
select pizza_name,count(distinct pizza_category) as category_count from pizaa
group by pizza_name
having category_count>1;
select pizza_name,pizza_category from pizaa
