/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
SELECT customer_id,
SUM(price) AS total_price
FROM sales AS s
INNER JOIN menu AS m
ON s.product_id = m.product_id
GROUP BY customer_id

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id,
COUNT(DISTINCT(order_date)) AS total_visits
FROM sales AS s
GROUP BY customer_id

-- 3. What was the first item from the menu purchased by each customer?
WITH CTE AS (
SELECT
s.customer_id,
s.order_date,
m.product_name,
RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS rnk,
ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) AS rn
FROM sales AS s
JOIN menu AS m
ON s.product_id = m.product_id
)
SELECT customer_id,
product_name
FROM CTE
WHERE rn = 1

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT TOP 1
product_name,
COUNT(order_date) AS orders
FROM sales AS s
JOIN menu AS m
ON s.product_id = m.product_id
GROUP BY product_name
ORDER BY COUNT(order_date) DESC

-- 5. Which item was the most popular for each customer?
WITH CTE AS (
SELECT
customer_id,
product_name,
COUNT(order_date) AS orders,
RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(order_date) DESC) AS rnk
FROM sales AS s
JOIN menu AS m
ON s.product_id = m.product_id
GROUP BY product_name,
customer_id
)
SELECT customer_id,
product_name
FROM CTE WHERE rnk = 1

-- 6. Which item was purchased first by the customer after they became a member?
WITH CTE AS (
SELECT s.customer_id,
order_date,
join_date,
product_name,
RANK() OVER(PARTITION BY s.customer_id ORDER BY order_date) AS rnk
FROM sales s
JOIN members m
ON s.customer_id = m.customer_id
JOIN menu me
ON s.product_id = me.product_id
WHERE order_date >= join_date
)
SELECT customer_id,
product_name
FROM CTE
WHERE rnk = 1

-- 7. Which item was purchased just before the customer became a member?
WITH CTE AS (
SELECT s.customer_id,
order_date,
join_date,
product_name,
RANK() OVER(PARTITION BY s.customer_id ORDER BY order_date DESC) AS rnk
FROM sales s
JOIN members m
ON s.customer_id = m.customer_id
JOIN menu me
ON s.product_id = me.product_id
WHERE order_date < join_date
)
SELECT customer_id,
order_date,
product_name
FROM CTE
WHERE rnk = 1

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id,
COUNT(product_name) AS total_items,
SUM(price) AS amount_spent
FROM sales s
JOIN members m
ON s.customer_id = m.customer_id
JOIN menu me
ON s.product_id = me.product_id
WHERE order_date < join_date
GROUP BY s.customer_id

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT customer_id,
SUM(CASE
WHEN product_name = 'sushi' THEN price * 10 * 2
ELSE price * 10
END) as points
FROM menu AS m
JOIN sales AS s
ON m.product_id = s.product_id
GROUP BY customer_id

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
SELECT s.customer_id,
--s.order_date,
--mem.join_date AS offer_start,
--DATEADD(day,6,mem.join_date) AS offer_end,
SUM(CASE
WHEN order_date BETWEEN mem.join_date AND DATEADD(day,6,mem.join_date) THEN price * 10 * 2
WHEN product_name = 'sushi' THEN price * 10 * 2
ELSE price * 10
END) as points
--DATETRUNC(month,order_date)
FROM menu AS m
JOIN sales AS s
ON m.product_id = s.product_id
JOIN members AS mem
ON mem.customer_id = s.customer_id
WHERE DATETRUNC(month,order_date) = '2021-01-01'
GROUP BY s.customer_id