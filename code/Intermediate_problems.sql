--q20
SELECT categories.category_name, COUNT(products.category_id) AS total_proudcts
FROM categories 
JOIN products ON categories.category_id = products.category_id
GROUP BY products.category_id, categories.category_name
ORDER BY total_proudcts DESC;

--q21
SELECT country, city, COUNT(*) AS total_customers FROM customers GROUP BY city, country ORDER BY total_customers DESC;

--q22
SELECT product_id, product_name, units_in_stock, reorder_level FROM products WHERE units_in_stock <= reorder_level ORDER BY product_id;

--q23
SELECT product_id, product_name, units_in_stock, units_on_order, reorder_level, discontinued 
FROM products 
WHERE units_in_stock + units_on_order <= reorder_level AND discontinued = 0
ORDER BY product_id;

--q24
SELECT customer_id, company_name, region FROM customers ORDER BY region, customer_id;

--q25
SELECT ship_country, AVG(freight) AS average_freight FROM orders GROUP BY ship_country ORDER BY average_freight DESC LIMIT 3;

--q26
SELECT ship_country, AVG(freight) AS average_freight FROM orders WHERE date_part('year', order_date) = 2015 GROUP BY ship_country ORDER BY average_freight DESC LIMIT 3;
--or 
SELECT ship_country, AVG(freight) AS average_freight FROM orders WHERE EXTRACT('year' from order_date) = 2015 GROUP BY ship_country ORDER BY average_freight DESC LIMIT 3;

--q27
-- sql server: In this problem we recive the code with BETWEEN '20150101' and '20151231' part. in sql server it is incorrect.
-- we look for missing order_id in france
SELECT ship_country, AVG(freight) AS average_freight FROM orders WHERE order_date BETWEEN '20150101' and '20151231' GROUP BY ship_country ORDER BY average_freight DESC LIMIT 3;

--in postgres we dont have this problem, but if i need to guess we can see that are two rows in 31/12/2015. 
--SQL server probably dont include them. order_id 10806 have high freight.
SELECT * FROM orders WHERE order_date='20150101' OR order_date='20151231' ORDER BY order_date;

--q28
SELECT ship_country, AVG(freight) AS average_freight 
FROM orders 
WHERE (SELECT max(order_date) FROM orders)-INTERVAL '12 months' <= order_date
GROUP BY ship_country 
ORDER BY average_freight DESC LIMIT 3;

--q29
SELECT em.employee_id, em.last_name, o.order_id, p.product_name, od.quantity
FROM orders AS o
JOIN employees AS em ON o.employee_id=em.employee_id
JOIN order_details AS od ON o.order_id=od.order_id
JOIN products AS p on od.product_id=p.product_id
ORDER BY o.order_id, p.product_id;

