CREATE DATABASE PIZZAHUT;
USE PIZZAHUT;
SELECT 
    *
FROM
    pizzas;

CREATE TABLE orders (
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    PRIMARY KEY (order_id)
);
 
 CREATE TABLE orders_details (
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (order_details_id)
);

-- Retrieve the total number of order placed,
SELECT 
    COUNT(order_id)
FROM
    orders;

-- Calculate the total revenue generated from pizza sales
SELECT 
    (orders_details.quantity * pizzas.price) AS total_sales
FROM
    orders_details
        JOIN
    pizzas ON pizzas.pizza_id = orders_details.pizza_id;

-- Identify the highest price pizza
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT 
    pizzas.size,
    COUNT(orders_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name, SUM(orders_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY (pizza_types.name)
ORDER BY quantity DESC
LIMIT 5;

-- Intermediate Query:
--  Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    SUM(orders_details.quantity),
    pizza_types.category AS category
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.category
ORDER BY category DESC;

-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS quantity
FROM
    orders
GROUP BY HOUR(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(pizza_type_id) AS count
FROM
    pizza_types
GROUP BY category
ORDER BY count DESC;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(total), 0) AS avg_pizza_order_per_day
FROM
    (SELECT 
        orders.order_date, SUM(orders_details.quantity) AS total
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date) AS order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name,
    SUM(orders_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

/* Advanced:
Calculate the percentage contribution of each pizza type to total revenue.
*/
SELECT 
    pizza_types.category,
    ROUND((SUM(orders_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(orders_details.quantity * pizzas.price),
                                1) AS total_sales
                FROM
                    orders_details
                        JOIN
			pizzas ON pizzas.pizza_id = orders_details.pizza_id)) * 100,
            1) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;

--  Analyze the cumulative revenue generated over time.
select order_date, sum(revenue) over (order by order_date) as cumm_revenue
from
(select orders.order_date, sum(orders_details.quantity * pizzas.price) as revenue
from orders join orders_details
on orders.order_id = orders_details.order_id
join pizzas
on pizzas.pizza_id = orders_details.pizza_id
group by orders.order_date) as sales; 

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category , name , revenue
from
(select category, name, revenue,
rank() over( partition by category order by revenue desc) as rn
from
(SELECT 
    pizza_types.category,
    pizza_types.name,
    SUM(orders_details.quantity * pizzas.price) AS revenue
FROM pizza_types join pizzas
ON  pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details
ON  orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category, pizza_types.name) as a )as b
where rn < 4;








