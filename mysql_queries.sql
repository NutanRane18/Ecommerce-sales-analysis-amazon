select * from amazon_sales_dataset;

update amazon_sales_dataset set order_date= str_to_date(date,"%d-%M-%Y");

alter table amazon_sales_dataset 
add column mnth varchar(10) after order_date;

set sql_safe_updates=0;
UPDATE amazon_sales_dataset
SET mnth = MONTHNAME(order_date);

create view price_detail as
(select order_id,product_id,
quantity_sold,price,discount_percent,
round(price*quantity_sold*discount_percent,2) as discount,
round(price*quantity_sold,2) as gross_revenue,
round(discounted_price*quantity_sold,2) as net_revenue
from amazon_sales_dataset);
select * from price_detail;

-- KPI's 
-- 1. total_revenue
select concat('$',round(sum(total_revenue)/1000000,2),' M') as Net_Revenue from amazon_sales_dataset;

-- 2. total_orders
select concat(round(count(order_id)/1000),' K') as Total_orders from amazon_sales_dataset;

-- 3. Quantity_sold
select concat(round(sum(quantity_sold)/1000),' K') as Units_sold from amazon_sales_dataset;

-- 4. avg_order_value
select round(sum(total_revenue)/count(order_id),2) as AOV from amazon_sales_dataset;

-- 5. avg_ratings
select ROUND(AVG(cast(nullif(rating,'') as decimal(3,2))), 1) AS avg_rating from amazon_sales_dataset;

-- analysis
-- A) revneue 
-- i) by product_category
select product_category,concat('$',round(sum(total_revenue)/1000000,2),' M') as net_revenue 
from amazon_sales_dataset 
group by product_category 
order by net_revenue desc;

-- ii) by customer region
select customer_region,concat('$',round(sum(total_revenue)/1000000,2),' M') as net_revenue 
from amazon_sales_dataset 
group by customer_region
order by net_revenue desc;

-- iii) by payment method
select payment_method, concat('$',round(sum(total_revenue)/1000000,2),' M') as net_revenue
from amazon_sales_dataset
group by payment_method
order by net_revenue desc;

-- B) order count
-- i) by product_category
select product_category,count(order_id) as Total_orders
from amazon_sales_dataset 
group by product_category
order by Total_orders desc;

-- ii) by customer region
select customer_region,count(order_id) as Total_orders
from amazon_sales_dataset 
group by customer_region
order by Total_orders desc;

-- iii) by payment_method
select payment_method,count(order_id) as Total_orders
from amazon_sales_dataset 
group by payment_method
order by Total_orders desc;

-- trend analysis
select mnth as month_name,
count(order_id) as Total_orders ,
concat('$',round(sum(total_revenue)/1000000,2),' M') as net_revenue,
round(sum(total_revenue)/count(order_id),2) as AOV
from amazon_sales_dataset group by month(order_date),month_name ORDER BY month(order_date);

-- product category summary
select product_category,
count(order_id) as Total_Orders,
concat(round(sum(quantity_sold)/1000,1),' K') as Units_sold,
concat('$',round(sum(total_revenue)/1000000,2),' M') as net_revenue,
concat('$',round(sum(total_revenue)/count(order_id),2)) as AOV,
ROUND(AVG(cast(nullif(rating,'') as decimal(3,2))), 1) AS avg_rating,
concat(round(sum(review_count)/100000,2),' L') as review_count
from amazon_sales_dataset group by product_category;

-- impact of discount on revenue, order and quantity
select discount_percent,
count(order_id) as Total_Orders,
concat(round(sum(quantity_sold)/1000,1),' K') as Units_sold,
concat('$',round(sum(total_revenue)/1000000,2),' M') as net_revenue
from amazon_sales_dataset
group by discount_percent order by discount_percent;