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
-- or book way - more flexable
SELECT ship_country, AVG(freight) AS average_freight FROM orders WHERE order_date >= '20150101' AND order_date < '20160101' GROUP BY ship_country ORDER BY average_freight DESC LIMIT 3;

--q27
-- sql server: In this problem we recive the code with BETWEEN '20150101' and '20151231' part. in sql server it is incorrect.
-- we look for missing order_id in france
SELECT ship_country, AVG(freight) AS average_freight FROM orders WHERE order_date BETWEEN '20150101' and '20151231' GROUP BY ship_country ORDER BY average_freight DESC LIMIT 3;

--in postgres we dont have this problem, but if i need to guess we can see that are two rows in 31/12/2015. 
--SQL server probably dont include them. order_id 10806 have high freight.
--book answer: in sql server the field is datetime which cause problem for the between.
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

--q30
SELECT c.customer_id AS customers_customer_id , o.customer_id AS orders_customer_id
FROM customers AS c
LEFT JOIN orders AS o ON c.customer_id = o.customer_id
WHERE o.customer_id ISNULL;

--the book recomeded this method for performance
SELECT customer_id 
FROM customers AS c
WHERE customer_id not in (SELECT customer_id from orders)

--q31
-- stack overflow method
SELECT DISTINCT c.customer_id
FROM customers c 
LEFT JOIN orders o on c.customer_id = o.customer_id
WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id AND o.employee_id=4)

-- book answer
SELECT customers.customer_id, orders.customer_id, orders.employee_id
FROM customers 
LEFT JOIN orders ON orders.customer_id = customers.customer_id AND orders.employee_id = 4
--WHERE orders.customer_id is null
--Order BY customers.customer_id
