--q20
SELECT categories.category_name, COUNT(products.category_id) AS total_proudcts
FROM categories 
JOIN products ON categories.category_id = products.category_id
GROUP BY products.category_id, categories.category_name
ORDER BY total_proudcts DESC;

--q21
SELECT country, city, COUNT(*) AS total_customers FROM customers GROUP BY city, country ORDER BY total_customers DESC;

--q22
