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

--q42
WITH late_orders_employee AS (
select employee_id, count(employee_id) AS total_late_orders
from orders
WHERE shipped_date::date >= required_date::date
GROUP BY employee_id)

SELECT late_orders_employee.employee_id ,last_name, late_orders_employee.total_late_orders
FROM employees
JOIN late_orders_employee ON employees.employee_id = late_orders_employee.employee_id
ORDER BY total_late_orders DESC ,late_orders_employee.employee_id

SELECT * from orders limit 2;
SELECT * from employees limit 2;

--q43
--get all late orders for each employeew (ith have late orders)
WITH late_orders_employee AS (
       select employee_id, count(employee_id) AS total_late_orders
       from orders
       WHERE shipped_date::date >= required_date::date
       GROUP BY employee_id),
--get all orders for each employee
all_orders_employee AS (
       select employee_id, count(employee_id) AS all_orders
       from orders
       GROUP BY employee_id)
--join them
SELECT late.employee_id ,last_name, total.all_orders, late.total_late_orders
FROM employees AS em
JOIN late_orders_employee as late ON em.employee_id = late.employee_id
JOIN all_orders_employee as total ON total.employee_id = late.employee_id
ORDER BY late.employee_id

--q44 + q45 + q46 + q47
-- q45 ask the user to change the null of employee id 5 to 0. I add the case to this problem.
-- q46 ask the user to calculate precentes, I used case because because of the null. probably is better to use another cte
-- q47 ask to round up to 2 digits after the point. 
WITH late_orders_employee AS (
       select employee_id, count(employee_id) AS total_late_orders
       from orders
       WHERE shipped_date::date >= required_date::date
       GROUP BY employee_id),
--get all orders for each employee
all_orders_employee AS (
       select employee_id, count(employee_id) AS all_orders
       from orders
       GROUP BY employee_id)
--join them
SELECT em.employee_id ,last_name, total.all_orders, late.total_late_orders,
       --case is the sulotion for q45 
       CASE
           WHEN late.total_late_orders IS NULL THEN 0
           ELSE late.total_late_orders
       END case_total_late_orders,
--the precent calculation is for q46, the round for q47
       CASE
          WHEN late.total_late_orders IS NULL THEN 0.00
          ELSE ROUND((late.total_late_orders/total.all_orders::numeric),2)  
       END precent_late_order
FROM employees AS em
JOIN all_orders_employee as total ON total.employee_id = em.employee_id
LEFT JOIN late_orders_employee as late ON em.employee_id = late.employee_id
ORDER BY em.employee_id

--q48
--calculate total amount first
WITH total_orders as (
       select customer_id,
       round(sum(unit_price*quantity)::numeric, 2) AS total_order_amount
FROM order_details 
JOIN orders ON orders.order_id=order_details.order_id
WHERE order_date BETWEEN '20160101' AND '20161231'
GROUP BY customer_id)
--join the company names and use case to group
SELECT customers.customer_id, company_name, total_order_amount,
       CASE
           WHEN total_order_amount BETWEEN 0 AND 1000 THEN 'Low'
           WHEN total_order_amount BETWEEN 1000 AND 5000 THEN 'Medium'
           WHEN total_order_amount BETWEEN 5000 AND 10000 THEN 'High'
           WHEN total_order_amount > 10000 THEN 'VERY High'
           ELSE '0'
       END customer_group
FROM customers
JOIN total_orders ON total_orders.customer_id = customers.customer_id 
ORDER BY customers.customer_id;

--q49
--in q49 you need to fix customer_id MAISD which have a null becuase the using of between for money, which is good for integer, but not money.
--I guess in postgres that is not the case, it still know that 5000.20 is bigger then 5000 (and therefore in the high category).
--The author recomeneded to use:
--total_order_amount >= 0 and total_order_amount < 1000

--q50
--calculate total amount first
WITH total_orders as (
       select customer_id,
       round(sum(unit_price*quantity)::numeric, 2) AS total_order_amount
FROM order_details 
JOIN orders ON orders.order_id=order_details.order_id
WHERE order_date BETWEEN '20160101' AND '20161231'
GROUP BY customer_id),
--join the company names and use case to group
c_groups AS (
       SELECT customers.customer_id, company_name, total_order_amount,
       CASE
           WHEN total_order_amount BETWEEN 0 AND 1000 THEN 'Low'
           WHEN total_order_amount BETWEEN 1000 AND 5000 THEN 'Medium'
           WHEN total_order_amount BETWEEN 5000 AND 10000 THEN 'High'
           WHEN total_order_amount > 10000 THEN 'VERY High'
           ELSE '0'
       END customer_group
       FROM customers
       JOIN total_orders ON total_orders.customer_id = customers.customer_id)

SELECT customer_group, count(customer_group) AS total_in_group,
       count(customer_group)::numeric / (select count(customer_group) from c_groups) AS prcentage_in_group
FROM c_groups
GROUP BY customer_group
ORDER BY total_in_group DESC;

--q51
with total_orders AS (
       select customers.customer_id, customers.company_name, ROUND(sum((unit_price*quantity))::numeric, 2) AS total_order_amount 
       FROM order_details
       JOIN orders on order_details.order_id = orders.order_id
       JOIN customers on orders.customer_id = customers.customer_id
       WHERE order_date BETWEEN '20160101' AND '20161231'
       GROUP BY customers.customer_id, customers.company_name)

SELECT total_orders.customer_id, total_orders.company_name, total_orders.total_order_amount, ctg.customer_group_name 
FROM total_orders
JOIN customer_group_thresholds AS ctg ON total_orders.total_order_amount BETWEEN range_bottom AND range_top
ORDER BY total_orders.customer_id;

--q52
SELECT DISTINCT country FROM customers
UNION
SELECT DISTINCT country FROM suppliers
ORDER BY country;

--q53
-- in the answers she used two cte's insted of one, while it easier to read I don't find it make big diffrence in this case
WITH suppliers_countries AS (
       SELECT DISTINCT country FROM suppliers
)
SELECT DISTINCT suppliers_countries.country AS suppliers_country  ,customers.country AS customers_country 
FROM customers
FULL OUTER JOIN suppliers_countrys ON customers.country = suppliers_countries.country
ORDER BY customers_country, suppliers_country 

--q54
--before review the answer I used the commented part and all_countries table
-- in the answers she used isnull from sql_server. In postgres there isnt a function like that, you need to use coalesce
WITH total_customers_countries AS (
       SELECT country, count(country) AS total_customers 
       FROM customers 
       GROUP BY country
),
total_suppliers_countries AS (
       SELECT country, count(country) AS total_suppliers 
       FROM suppliers 
       GROUP BY country
),
all_countiers AS (
       SELECT DISTINCT country FROM customers
       UNION
       SELECT DISTINCT country FROM suppliers
)
SELECT coalesce(tcc.country, tsc.country) AS country, coalesce(tsc.total_suppliers, 0), coalesce(tcc.total_customers, 0)
from total_customers_countries AS tcc
FULL OUTER JOIN total_suppliers_countries AS tsc ON tcc.country = tsc.country
--FROM all_countiers as allc
--LEFT JOIN total_customers_countries tcc ON allc.country = tcc.country
--LEFT JOIN total_suppliers_countries tsc ON allc.country = tsc.country
ORDER BY country;

--q55
WITH rank_orders AS (
       SELECT ship_country, customer_id, order_id, order_date,
              ROW_NUMBER() OVER (PARTITION BY ship_country ORDER BY order_date) AS row_id
       FROM orders
       ORDER BY ship_country)
SELECT ship_country, customer_id, order_id, order_date
FROM rank_orders
WHERE row_id=1

--q56
--my code have a prblem because there need to be 71 rows. The book's answer is not clear where the issue
-- I found few missing rows, the fix was to move the comparasion of the order ids to the where part and change it from <> to <
SELECT 
       init_orders.customer_id,
       next_orders.order_id AS initial_order_id, next_orders.order_date AS initial_order_date, 
       init_orders.order_id AS next_order_id, init_orders.order_date AS next_order_date, 
       (init_orders.order_date::date - next_orders.order_date::date) AS day_between_orders
FROM orders AS init_orders 
JOIN orders AS next_orders
       ON next_orders.customer_id = init_orders.customer_id 
       --AND init_orders.order_date > next_orders.order_date
       AND (init_orders.order_date - next_orders.order_date) BETWEEN 0 AND 5
--WHERE  init_orders.customer_id = 'BOTTM' AND next_orders.order_id = 10410 AND 
WHERE next_orders.order_id < init_orders.order_id
ORDER BY init_orders.customer_id, initial_order_date, next_order_id

--q57
-- same thing as above but with window function
WITH next_order_dates AS (
       SELECT customer_id, order_date,
              LEAD(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS next_order
       FROM orders)
SELECT customer_id, order_date, next_order, 
       (next_order::date - order_date::date) AS day_between_orders
FROM next_order_dates
WHERE (next_order::date - order_date::date) BETWEEN 0 AND 5
ORDER BY customer_id
