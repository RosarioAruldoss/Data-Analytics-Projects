--To check the imported table and monitot the column data.
SELECT * FROM pizza_sales;

--KPIs
--1. Total Revenue: The sum of the total price of all pizza orders.

SELECT SUM(total_price) AS Total_Revenue FROM pizza_sales;
--The Total Revenue is : 817860.05083847

--2. Average Order Value: The average amount spent per order, calculated by dividing the total revenue by the total number of orders.

SELECT SUM(total_price)/COUNT(distinct(order_id)) AS Avg_Order_Value FROM pizza_sales;
--Average Order Value is : 38.3072623343546

--3. Total Pizzas Sold: The sum of the quantities of all pizzas sold.
SELECT SUM(quantity) AS Total_pizza_sold from pizza_sales;

--4. Total Orders: The total number of orders placed.
SELECT COUNT(distinct(order_id)) AS Total_Orders from pizza_sales;


--5. Average Pizzas Per Order: The average number of pizzas sold per order, calculated by dividing the total number of pizzas sold by the total number of orders.
SELECT CAST 
(CAST (SUM(quantity) AS DECIMAL(10,2)) / CAST (COUNT(DISTINCT order_id) AS DECIMAL(10,2)) 
AS DECIMAL(10,2)) 
AS Avg_Pizzas_per_order FROM pizza_sales;


-- CHARTS REQUIREMENT

-- 1. Daily Trend for Total Orders:
SELECT DATENAME(DW, order_date) AS Order_Day, COUNT (DISTINCT(order_id)) AS Total_orders 
from pizza_sales
ORDERS GROUP BY DATENAME(DW, order_date)
ORDER BY Total_orders DESC;

-- 2. Monthly Trend for Total Orders:
SELECT DATENAME(MONTH, order_date) AS Month_Name, COUNT (DISTINCT(order_id)) AS Total_orders 
from pizza_sales
ORDERS GROUP BY DATENAME(MONTH, order_date)
ORDER BY Total_orders DESC;

-- 3. Percentage of Sales by Pizza Category:

SELECT pizza_category, SUM(total_price) AS Total_Price, sum(total_price) * 100/(SELECT sum(total_price) FROM pizza_sales) AS PCT
FROM pizza_sales
WHERE MONTH(order_date) = 1
group by pizza_category
order by PCT desc;

-- 4. Percentage of Sales by Pizza Size:

SELECT pizza_size, SUM(total_price) AS Total_Price, sum(total_price) * 100/(SELECT sum(total_price) FROM pizza_sales) AS PCT
FROM pizza_sales
WHERE MONTH(order_date) = 1
group by pizza_size
order by PCT desc;

Generate a pie chart that represents the percentage of sales attributed to different pizza sizes. This chart will help us understand customer preferences for pizza sizes and their impact on sales.

### 5. Total Pizzas Sold by Pizza Category:

Create a funnel chart that presents the total number of pizzas sold for each pizza category. This chart will allow us to compare the sales performance of different pizza categories.

### 6. Top 5 Best Sellers by Revenue, Total Quantity and Total Orders:

Create a bar chart highlighting the top 5 best-selling pizzas based on the Revenue, Total Quantity, Total Orders. This chart will help us identify the most popular pizza options.

### 7. Bottom 5 Best Sellers by Revenue, Total Quantity and Total Orders:

Create a bar chart showcasing the bottom 5 worst-selling pizzas based on the Revenue, Total Quantity, Total Orders. This chart will enable us to identify underperforming or less popular pizza options.

Note: The heading in Point 7 should ideally read "Bottom 5 Worst Sellers." I have preserved the original text from the image.