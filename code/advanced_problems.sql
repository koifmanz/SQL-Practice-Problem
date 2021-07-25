--q32
SELECT c.customer_id, c.company_name, o.order_id, sum(od.unit_price*od.quantity) AS total_order_amount
FROM customers as c
JOIN orders as o ON c.customer_id = o.customer_id
JOIN order_details as od ON od.order_id = o.order_id
--WHERE date_part('year', o.order_date) = 2016 
WHERE order_date BETWEEN '20160101' and '20161231'
GROUP BY c.customer_id, c.company_name, o.order_id
HAVING sum((od.unit_price*od.quantity)) >= 10000
ORDER BY total_order_amount DESC;

--q33
--please see the diffrence where we stop group by at the company_name, not like the eralier problem
SELECT c.customer_id, c.company_name, sum(od.unit_price*od.quantity) AS total_order_amount
FROM customers as c
JOIN orders as o ON c.customer_id = o.customer_id
JOIN order_details as od ON od.order_id = o.order_id
WHERE order_date BETWEEN '20160101' and '20161231'
GROUP BY c.customer_id, c.company_name
HAVING sum((od.unit_price*od.quantity)) >= 15000
ORDER BY total_order_amount DESC;

--q34
SELECT c.customer_id, c.company_name, 
       sum(od.unit_price*od.quantity) AS total_order_amount,
       sum(od.unit_price*od.quantity*(1-od.discount)) AS total_order_amount_discount 
FROM customers as c
JOIN orders as o ON c.customer_id = o.customer_id
JOIN order_details as od ON od.order_id = o.order_id
WHERE order_date BETWEEN '20160101' and '20161231'
GROUP BY c.customer_id, c.company_name
HAVING sum((od.unit_price*od.quantity*(1-od.discount))) >= 15000
ORDER BY total_order_amount_discount DESC;

--q35
SELECT employee_id, order_id, order_date from orders
WHERE  date_part('DAY', order_date) = date_part('DAY' ,date_trunc('month', order_date) + interval '1 month' - interval '1 day')
ORDER BY employee_id, order_id;

--q36
SELECT order_id, count(order_id) as total_order_details from order_details group by order_id order by total_order_details DESC, order_id limit 10;

--q37
--first method - google, second method - myself and google
SELECT * FROM orders WHERE random() < 0.02;
SELECT order_id FROM orders ORDER BY random() LIMIT (SELECT count(*)*0.02 from orders);

--q38
SELECT order_id FROM order_details WHERE quantity >= 60 GROUP BY order_id, quantity HAVING count(quantity) > 1 order by order_id;

--q39
SELECT order_id, product_id, unit_price, quantity, discount 
FROM order_details 
WHERE order_id IN 
       (SELECT order_id 
       FROM order_details 
       WHERE quantity >= 60 
       GROUP BY order_id, quantity 
       HAVING count(quantity) > 1)
ORDER BY order_id;

--q40
--the following code from the book, it part of the problem, it return 20 rows (insted of 16)
SELECT order_details.order_id, product_id, unit_price, quantity, discount 
FROM order_details 
JOIN (SELECT order_id FROM order_details WHERE quantity >= 60 GROUP BY order_id, quantity HAVING count(quantity) > 1) as potenial_problem_orders
ON potenial_problem_orders.order_id = order_details.order_id
ORDER BY order_id, product_id;

-- the error is because there two same id on the join table, so distinct will fix it
SELECT order_details.order_id, product_id, unit_price, quantity, discount 
FROM order_details 
JOIN (SELECT DISTINCT order_id FROM order_details WHERE quantity >= 60 GROUP BY order_id, quantity HAVING count(quantity) > 1) as potenial_problem_orders
ON potenial_problem_orders.order_id = order_details.order_id
ORDER BY order_id, product_id;

--q41
select order_id, order_date, required_date, shipped_date 
from orders
WHERE shipped_date::date >= required_date::date
ORDER BY order_id;