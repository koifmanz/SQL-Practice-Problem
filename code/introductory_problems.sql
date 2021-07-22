-- q1
SELECT * from shippers;

-- q2
SELECT category_name, description FROM categories;

-- q3
SELECT first_name, last_name, hire_date FROM employees WHERE title='Sales Representative';

-- q4
SELECT first_name, last_name, hire_date FROM employees WHERE title='Sales Representative' AND country='USA';

--q5
SELECT order_id, order_date FROM orders WHERE employee_id = 5;

--q6
SELECT supplier_id, contact_name, contact_title FROM suppliers WHERE contact_title <> 'Marketing Manager';

--q7
SELECT * FROM products WHERE lower(product_name) LIKE '%queso%';

--q8
SELECT order_id, customer_id, ship_country FROM orders WHERE ship_country IN ('France', 'Belgium');

--q9
SELECT order_id, customer_id, ship_country FROM orders WHERE ship_country IN ('Brazil', 'Mexico', 'Argentina', 'Venezuela');

--q10
SELECT first_name, last_name, title, birth_date FROM employees ORDER BY birth_date asc;

--q11
SELECT first_name, last_name, title, birth_date::timestamp FROM employees ORDER BY birth_date asc;

--q12
SELECT first_name, last_name, (first_name || ' ' || last_name) as full_name FROM employees;  

--q13
SELECT order_id, product_id, unit_price, quantity, 
       round((unit_price * quantity)::numeric, 2) as total_price
FROM order_details;

--q14
SELECT COUNT(customers) FROM customers;

--q15 
SELECT MIN(order_date) AS first_order FROM orders;

--q16
 SELECT DISTINCT(country) FROM customers ORDER BY country;

 --q17
 SELECT contact_title, COUNT(contact_title) as total_contact_title FROM customers GROUP BY contact_title ORDER BY total_contact_title desc;

 --q18 
 SELECT product_id, product_name, suppliers.company_name AS supplier
 from products 
 JOIN suppliers ON products.supplier_id = suppliers.supplier_id
 ORDER BY product_id asc;

 --q19
 SELECT order_id, order_date, shippers.company_name AS shipper  FROM orders JOIN shippers ON orders.ship_via = shippers.shipper_id WHERE order_id < 10270;