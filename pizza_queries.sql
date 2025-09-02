-- SQL Questions and Queries

-- 1. Retrieve the total number of orders placed.
SELECT SUM(quantity) AS Total_Orders  
FROM order_details;

-- 2. Calculate the total revenue generated from pizza sales.
SELECT SUM(o.quantity * p.price) AS total_revenue  
FROM pizza p  
JOIN order_details o ON o.pizza_id = p.pizza_id;

-- 3. Identify the highest-priced pizza.
SELECT pizza_types.name, pizza.price  
FROM pizza  
JOIN pizza_types ON pizza.pizza_type_id = pizza_types.pizza_type_id  
ORDER BY price DESC  
LIMIT 1;

-- 4. Identify the most commonly ordered pizza size.
SELECT pizza.pizza_size, COUNT(order_details.order_id) AS order_count  
FROM pizza  
JOIN order_details ON pizza.pizza_id = order_details.pizza_id  
GROUP BY pizza.pizza_size  
ORDER BY order_count DESC  
LIMIT 1;

-- 5. List the top 5 pizza types along with their quantities.
SELECT pizza_types.name, SUM(order_details.quantity) AS total_quantity  
FROM pizza  
JOIN pizza_types ON pizza_types.pizza_type_id = pizza.pizza_type_id  
JOIN order_details ON order_details.pizza_id = pizza.pizza_id  
GROUP BY pizza_types.name  
ORDER BY total_quantity DESC  
LIMIT 5;

-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pizza_types.category, SUM(order_details.quantity) AS total_quantity  
FROM pizza  
JOIN pizza_types ON pizza_types.pizza_type_id = pizza.pizza_type_id  
JOIN order_details ON order_details.pizza_id = pizza.pizza_id  
GROUP BY pizza_types.category;

-- 7. Determine the distribution of orders by hour of the day.
SELECT EXTRACT(HOUR FROM order_time) AS ord_time, COUNT(order_id) AS total_orders  
FROM orders  
GROUP BY ord_time  
ORDER BY ord_time DESC;

-- 8. Join relevant tables to find the category-wise distribution of pizzas.
SELECT category, COUNT(name) AS total_pizza  
FROM pizza_types  
GROUP BY category;

-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(AVG(total_quantity), 0) AS average_pizza_per_day  
FROM (  
    SELECT orders.order_date, SUM(order_details.quantity) AS total_quantity  
    FROM order_details  
    JOIN orders ON orders.order_id = order_details.order_id  
    GROUP BY orders.order_date  
) AS order_quantity;

-- 10. Determine the top 3 most ordered pizza types based on revenue.
SELECT pizza_types.category, SUM(order_details.quantity * pizza.price) AS total_revenue  
FROM pizza  
JOIN order_details ON order_details.pizza_id = pizza.pizza_id  
JOIN pizza_types ON pizza_types.pizza_type_id = pizza.pizza_type_id  
GROUP BY pizza_types.category  
ORDER BY total_revenue DESC  
LIMIT 3;

-- 11. Calculate the percentage contribution of each pizza type to total revenue.
SELECT pizza_types.category,  
       SUM(order_details.quantity * pizza.price) AS total_revenue,  
       ROUND((SUM(order_details.quantity * pizza.price) * 100.0 /  
             SUM(SUM(order_details.quantity * pizza.price)) OVER ()), 2) AS percentage_contribution  
FROM pizza  
JOIN order_details ON order_details.pizza_id = pizza.pizza_id  
JOIN pizza_types ON pizza_types.pizza_type_id = pizza.pizza_type_id  
GROUP BY pizza_types.category  
ORDER BY total_revenue DESC;

-- 12. Analyze the cumulative revenue generated over time.
SELECT order_date, SUM(revenue) OVER (ORDER BY order_date) AS cum_revenue  
FROM (  
    SELECT orders.order_date,  
           SUM(order_details.quantity) AS revenue,  
           SUM(order_details.quantity) AS total_quantity  
    FROM order_details  
    JOIN orders ON orders.order_id = order_details.order_id  
    GROUP BY orders.order_date  
    ORDER BY orders.order_date  
) AS sales;

-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT name, category, revenue  
FROM (  
    SELECT category, name, revenue,  
           RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn  
    FROM (  
        SELECT pizza_types.category, pizza_types.name,  
               SUM(order_details.quantity) AS revenue,  
               SUM(order_details.quantity * pizza.price) AS total_revenue  
        FROM pizza  
        JOIN order_details ON order_details.pizza_id = pizza.pizza_id  
        JOIN pizza_types ON pizza_types.pizza_type_id = pizza.pizza_type_id  
        GROUP BY pizza_types.category, pizza_types.name  
        ORDER BY total_revenue DESC  
    ) AS a  
) AS b  
WHERE rn <= 3;
