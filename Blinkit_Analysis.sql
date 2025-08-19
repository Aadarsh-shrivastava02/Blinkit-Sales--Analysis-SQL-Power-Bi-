select*from blinkit_order_items;
select*from blinkit_customers;
select*from blinkit_delivery_performance;
select*from blinkit_inventory;
select*from blinkit_marketing_performance;
select*from blinkit_orders;
select*from blinkit_products;

#1.	Top 10 selling products

select p.product_name,
o.product_id,
sum(o.quantity)as total_quantity 
from blinkit_order_items o 
left join  blinkit_products p 
on o.product_id = p. product_id
group by o.product_id , p.product_name
order by total_quantity desc Limit 10;



#1.	Total sale in every month year
select round(sum(order_total),2) as total_order_amount from blinkit_orders;

#total _ Revenue
select sum(quantity*unit_price) as total_revenue from blinkit_order_items;

#year wise revenue
select date_format(o.order_date, '%Y') as year,
sum(oi.quantity*oi.unit_price) as total_revenue from blinkit_order_items oi
join blinkit_orders o
on o.order_id = oi.order_id
group by date_format(o.order_date,'%Y')
order by year;

#2. Peak sales months / seasons
select date_format(o.order_date, '%Y-%M') as Month,
round(sum(oi.quantity*oi.unit_price)) as total_revenue from blinkit_order_items oi
join blinkit_orders o
on o.order_id = oi.order_id
group by date_format(o.order_date,'%Y-%M')
order by total_revenue DESC
Limit 4;

# Highest order get in a day
SELECT 
    DATE(o.order_date) AS order_day,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM blinkit_orders o
GROUP BY order_day
ORDER BY total_orders desc;

# Monthwiae wise total Sale
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM blinkit_orders o
GROUP BY month
ORDER BY total_orders desc;


use blink_it

# Average order value.
select avg(order_total) from blinkit_orders



#Customer purchase frequency.
SELECT 
    AVG(order_count) AS avg_orders_per_customer
FROM (
    SELECT 
        customer_id,
        COUNT(order_id) AS order_count
    FROM blinkit_orders
    WHERE order_date BETWEEN '2022-01-01' AND '2025-01-31'
    GROUP BY customer_id
) AS customer_orders;


# 7. Order growth rate month-on-month
with monthly_orders as (
select date_format(order_date,'%Y-%m') as month,
count(distinct order_id) as total_orders
from blinkit_orders
group by date_format(order_date,'%Y-%m')
)
select month,total_orders,
LAG(total_orders, 1) OVER (ORDER BY month) AS prev_month_orders,
    ROUND(
        ((total_orders - LAG(total_orders, 1) OVER (ORDER BY month)) 
        / LAG(total_orders, 1) OVER (ORDER BY month)) * 100, 2
    ) AS growth_rate_percent
FROM monthly_orders;



# Best-selling products by quantity.
select p.product_name,sum(i.quantity) as total_sale from blinkit_products p Left Join blinkit_order_items i on p.product_id = i.product_id
group by product_name
order by total_sale
desc;




# Revenue contribution of each product.
select p.product_name,Round(sum(i.unit_price),2) as total_sale_revenue from blinkit_products p Left Join blinkit_order_items i on p.product_id = i.product_id
group by product_name
order by total_sale_revenue
desc;




#4. Top-performing cities by revenue
SELECT 
    c.area,
    round(SUM(oi.quantity * oi.unit_price),2 )AS total_revenue
FROM blinkit_orders o
JOIN blinkit_customers c ON o.customer_id = c.customer_id
JOIN blinkit_order_items oi ON o.order_id = oi.order_id
GROUP BY c.area
ORDER BY total_revenue DESC
LIMIT 10;

#Average delivery time
SELECT 
    ROUND(AVG(delivery_time_minutes), 2) AS avg_delivery_time
FROM blinkit_delivery_performance;

#Best & worst delivery partners
SELECT 
    delivery_partner_id,
    ROUND(AVG(delivery_time_minutes), 2) AS avg_delivery_time
FROM blinkit_delivery_performance
GROUP BY delivery_partner_id
ORDER BY avg_delivery_time ASC;  -- ASC = best first, DESC = worst first

#worst first
SELECT 
    delivery_partner_id,
    ROUND(AVG(delivery_time_minutes), 2) AS avg_delivery_time
FROM blinkit_delivery_performance
GROUP BY delivery_partner_id
ORDER BY avg_delivery_time desc;  -- ASC = best first, DESC = worst first

#Late delivery percentage
SELECT 
    ROUND(SUM(CASE WHEN delivery_status = 'Slightly Delayed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS late_delivery_percent
FROM blinkit_delivery_performance;

# Which product category generates the highest revenue in each city?
WITH city_category_revenue AS (
    SELECT 
        c.area,
        p.category,
        ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue,
        ROW_NUMBER() OVER (PARTITION BY c.area ORDER BY SUM(oi.quantity * oi.unit_price) DESC) AS rn
    FROM blinkit_order_items oi
    JOIN blinkit_orders o 
        ON oi.order_id = o.order_id
    JOIN blinkit_products p 
        ON oi.product_id = p.product_id
    JOIN blinkit_customers c 
        ON o.customer_id = c.customer_id
    GROUP BY c.area, p.category
)
SELECT area, category, total_revenue
FROM city_category_revenue
WHERE rn = 1
ORDER BY total_revenue DESC;






