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