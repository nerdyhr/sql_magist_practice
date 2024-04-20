use magist;

/*tables that don't change until a purchase or order is made */

select * from products;
select * from product_category_name_translation;
select * from sellers;
select * from customers;
select * from geo;

/*tables capturing purhcase*/
select * from orders;
select * from order_items;
select * from order_reviews where review_score = 1;
select * from order_payments;

/*How many orders are there in the dataset?*/
select count(order_id) from orders;
select count(order_id) from order_items;
select count(distinct order_id) from order_items;


/*Counts of order statuses*/
select order_status, count(order_id) from orders group by order_status;

/* user growth story over time */
SELECT YEAR (order_purchase_timestamp)as year ,MONTH(order_purchase_timestamp) as month, count(customer_id) as total_customers 
FROM orders 
group by YEAR (order_purchase_timestamp),MONTH(order_purchase_timestamp) order by YEAR (order_purchase_timestamp),MONTH(order_purchase_timestamp) ASC ;

/*how many unique products?*/
select * from products;

select count(distinct(product_id)) as unique_products from products;

/*Which are the categories with the most products?*/
select pc.product_category_name_english, count(p.product_id) as total_count 
from products as p
join product_category_name_translation as pc
on p.product_category_name = pc.product_category_name
group by pc.product_category_name_english;

select product_category_name_english, count(product_id) as total_count 
from products
join product_category_name_translation
using (product_category_name)
group by product_category_name_english;

/*How many of those products were present in actual transactions?*/
select count(distinct product_id) from order_items;

/*What’s the price for the most expensive and cheapest products?*/
select MAX(price) as expensive, MIN(price) as cheapest from order_items;


(select product_id, price
from order_items
order by price desc
limit 1)
union
(select product_id, price
from order_items
order by price asc
limit 1);

/*What is the max an min payment value*/
SELECT 
	MAX(payment_value) as highest,
    MIN(payment_value) as lowest
FROM
	order_payments
WHERE
payment_value <> 0;

/*Answering business questions-----------------------------------------------------------------------*/
/* This query classifies the mapping table products into tech non tech and joins it with total orders from order items via products table*/
with productclassification as
(select * ,
case when product_category_name_english IN ("air_conditioning","electronics","home_appliances","home_appliances_2","small_appliances","computers_accessories", "computers") then "Tech"
else "Non tech"
end as Tech_NonTech_Classification
from product_category_name_translation
)
select sum(order_counts.total_orders) as total_orders, productclassification.Tech_NonTech_Classification
from 
(select count(order_id) as total_orders, product_category_name 
from order_items
join products
using (product_id)
group by product_category_name) as order_counts
join productclassification 
on order_counts.product_category_name = productclassification.product_category_name
group by productclassification.Tech_NonTech_Classification;


/* what percentage does that represent overall number of products sold*/
select count(distinct product_id)
from order_items;

/* what is avg price of products sold*/
select round(avg(price),2)
from order_items;

/* are expensive tech products popular?*/
select CASE 
when price > 500 then 'Expensive'
when price > 100 then 'Mid-level'
else 'Cheap'
end as price_range, count(product_id)
from order_items
left join products
	using (product_id)
left join product_category_name_translation
	using (product_category_name)
where product_category_name_english IN ("electronics","home_appliances","home_appliances_2","small_appliances","computers_accessories", "computers")
group by price_range;

/*how many orders delivered on time vs delayed*/
Select CASE
when datediff(order_estimated_delivery_date,order_delivered_customer_date ) >0 then "Delayed"
Else "On time"
end as delivery_status, count(order_id)
from orders
where order_status = 'delivered'
group by delivery_status;


select * from product_category_name_translation;

select count(*) from sellers;

