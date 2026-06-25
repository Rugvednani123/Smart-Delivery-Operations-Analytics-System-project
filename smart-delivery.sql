
CREATE TABLE customers(
customer_id INT PRIMARY KEY,
customer_name VARCHAR(100) NOT NULL,
age INT CHECK (age >=18),
gender VARCHAR(50) CHECK (gender IN ('Male','Female','Other')),
city VARCHAR(100) NOT NULL,
signup_date DATE NOT NULL);

SELECT * FROM customers;
CREATE TABLE customer_behaviour(
customer_id INT PRIMARY KEY,
total_orders INT NOT NULL,
total_spending DECIMAL(10,2) NOT NULL,
avg_order_value DECIMAL(10,2) NOT NULL,
last_order_days INT NOT NULL,
churn_flag BOOLEAN NOT NULL,
FOREIGN KEY(customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE);

CREATE TABLE delivery_partners(
partner_id INT PRIMARY KEY,
partner_name VARCHAR(100) NOT NULL,
vehicle_type VARCHAR(100) NOT NULL CHECK (vehicle_type IN ('Bike','Scooter','Bicycle','Electric Bike')),
joining_date DATE NOT NULL);

CREATE TABLE orders(
order_id INT PRIMARY KEY,
customer_id INT NOT NULL,
restaurant_id INT NOT NULL,
partner_id INT NOT NULL,
order_time TIMESTAMP NOT NULL,
delivered_time TIMESTAMP NULL,
order_amount DECIMAL(10,2),
delivery_fee DECIMAL(6,2),
status VARCHAR(100) CHECK (status IN ('Delivered','Cancelled','Pending')),
FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id),
FOREIGN KEY (partner_id) REFERENCES delivery_partners(partner_id)
);

CREATE TABLE payments(
payment_id INT PRIMARY KEY,
order_id INT NOT NULL,
payment_mode VARCHAR(100) NOT NULL CHECK ( payment_mode IN ('UPI','Credit Card','Debit Card','Cash on Delivery','Wallet')),
amount DECIMAL(10,2) NOT NULL,
FOREIGN KEY (order_id)REFERENCES orders(order_id) ON DELETE CASCADE);

CREATE TABLE ratings(
rating_id INT PRIMARY KEY,
order_id INT NOT NULL,
customer_rating DECIMAL(2,1) CHECK (customer_rating BETWEEN 1.0 AND 5.0),
feedback VARCHAR(300),
FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE);

CREATE TABLE restaurants(
restaurant_id INT PRIMARY KEY,
restaurant_name VARCHAR(100) NOT NULL,
cuisine_type VARCHAR(100) NOT NULL,
city VARCHAR(50) NOT NULL,
rating DECIMAL(2,1) NOT NULL CHECK (rating BETWEEN 1.0 AND 5.0));

SELECT * FROM customers;
SELECT * FROM restaurants;

SELECT * FROM delivery_partners;

SELECT * FROM orders;

SELECT COUNT(*) AS count_o FROM orders;

SELECT * FROM payments;

SELECT * FROM ratings;

SELECT * FROM customer_behaviour;
SELECT * FROM restaurants;

DESC customers;

DESC restaurants;

DESC delivery_partners;

DESC orders;

DESC payments;

DESC ratings;

DESC customer_behavior;

SELECT COUNT(*) FROM orders;


UPDATE orders
SET delivered_time = order_time
WHERE delivered_time IS NULL;

SELECT order_amount FROM orders WHERE order_amount IS NULL;
SELECT delivery_fee FROM orders WHERE delivery_fee IS NULL;

SELECT *
FROM orders
WHERE delivered_time IS NULL;

SELECT customer_id, COUNT(*) AS duplicate_count
FROM customer_behaviour
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT order_id,
       COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

GROUP BY order_id,
         customer_id,
         restaurant_id,
         partner_id
HAVING COUNT(*) > 1;

SELECT status FROM orders WHERE status IS NULL;


SELECT order_id,
       customer_id,
       restaurant_id,
       partner_id,
       COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id,
         customer_id,
         restaurant_id,
         partner_id
HAVING COUNT(*) > 1;

SELECT order_id,count(*) FROM payments GROUP BY order_id HAVING COUNT(*) >1;

SELECT payment_id,
       order_id,
       payment_mode,
       amount,
       COUNT(*) AS duplicate_count
FROM payments
GROUP BY payment_id,
         order_id,
         payment_mode,
         amount
HAVING COUNT(*) > 1;

SELECT rating_id,
       order_id,
       customer_rating,
       feedback,
       COUNT(*) AS duplicate_count
FROM ratings
GROUP BY rating_id,
         order_id,
         customer_rating,
         feedback
HAVING COUNT(*) > 1;

SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT payment_id) AS unique_rows
FROM payments;

SELECT DISTINCT city from customers;

SELECT DISTINCT city FROM restaurants;

SELECT * FROM customers;
SELECT * FROM restaurants;
SELECT * FROM payments;
SELECT customer_name,UPPER(TRIM(customer_name)) FROM customers;
UPDATE customers SET customer_name = UPPER(TRIM(customer_name));
SELECT city ,UPPER(TRIM(city)) FROM customers;
UPDATE customers SET city = UPPER(TRIM(city));

SELECT restaurant_name,UPPER(TRIM(restaurant_name)) FROM restaurants;
UPDATE restaurants SET restaurant_name = UPPER(TRIM(restaurant_name));
UPDATE restaurants SET city = UPPER(TRIM(city));
UPDATE restaurants SET cuisine_type = UPPER(TRIM(cuisine_type));

SELECT DISTINCT payment_mode
FROM payments;

UPDATE payments SET payment_mode = TRIM(payment_mode);


SELECT COUNT(*) FROM payments;

SELECT * FROM delivery_partners;


UPDATE delivery_partners SET partner_name = UPPER(TRIM(partner_name));

SELECT *
FROM orders
WHERE order_amount < 0;

SELECT *
FROM orders
WHERE delivery_fee < 0;

SELECT *
FROM orders
WHERE delivery_fee < 0;

SELECT *
FROM orders
WHERE delivered_time < order_time;

SELECT *
FROM customers
WHERE age < 18
   OR age > 100;

SELECT * FROM ratings;


UPDATE ratings SET feedback = TRIM(feedback);
SELECT feedback, INITCAP(feedback) AS cap FROM ratings;
UPDATE ratings SET feedback = INITCAP(feedback);

SELECT feedback FROM ratings WHERE feedback IS NULL;

SELECT customer_rating FROM ratings WHERE customer_rating IS NULL;

--Which restaurants are associated with the longest average delivery times
SELECT r.restaurant_id,r.restaurant_name,ROUND(AVG(EXTRACT(EPOCH FROM (o.delivered_time - o.order_time))/60),2)AS avg_delivery_time FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id WHERE o.status = 'Delivered' 
GROUP BY r.restaurant_id,r.restaurant_name ORDER BY avg_delivery_time DESC;

--Which delivery partners have the highest average time per order
SELECT dp.partner_id,dp.partner_name,ROUND(AVG(EXTRACT(EPOCH FROM (o.delivered_time - o.order_time))/60),2) AS avg_delivery_time_minutes FROM orders o
JOIN delivery_partners dp ON o.partner_id = dp.partner_id WHERE o.status = 'Delivered'
GROUP BY dp.partner_id, dp.partner_name
ORDER BY avg_delivery_time_minutes DESC;

--Which cities experience the most delivery delays
SELECT r.city, ROUND(AVG(EXTRACT(EPOCH FROM (o.delivered_time - o.order_time))/60),2) AS avg_delivery_time_minutes FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id WHERE o.status = 'Delivered' GROUP BY r.city ORDER BY avg_delivery_time_minutes DESC;

--each day average  delivery time delay
SELECT DATE(order_time) AS order_date,ROUND(AVG(EXTRACT(EPOCH FROM (delivered_time - order_time))/60),2) AS avg_delivery_time_minutes
FROM orders WHERE status = 'Delivered'
GROUP BY DATE(order_time)
ORDER BY order_date;

--each month avgerage delivery time delay
SELECT TO_CHAR(order_time,'YYYY-MM') AS order_date,ROUND(AVG(EXTRACT(EPOCH FROM (delivered_time - order_time))/60),2) AS avg_delivery_time_minutes
FROM orders WHERE status = 'Delivered'
GROUP BY TO_CHAR(order_time,'YYYY-MM')
ORDER BY order_date;

--Monthly wise Cumulative Average Delay
WITH monthly_delivery AS
(SELECT TO_CHAR(order_time,'YYYY-MM') AS month,ROUND(AVG(EXTRACT(EPOCH FROM (delivered_time - order_time))/60),2) AS avg_delay
FROM orders
WHERE status = 'Delivered'
GROUP BY TO_CHAR(order_time,'YYYY-MM')
)
SELECT month, avg_delay, ROUND(AVG(avg_delay) OVER (ORDER BY month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),2) AS cumulative_avg_delay
FROM monthly_delivery
ORDER BY month;

--Top 10 fastest restaurants
SELECT r.restaurant_id,r.restaurant_name,ROUND(AVG(EXTRACT(EPOCH FROM (o.delivered_time - o.order_time))/60),2)AS avg_delivery_time FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id WHERE o.status = 'Delivered' 
GROUP BY r.restaurant_id,r.restaurant_name ORDER BY avg_delivery_time LIMIT 10;

--TOP 10 fastest cities
SELECT r.city, ROUND(AVG(EXTRACT(EPOCH FROM (o.delivered_time - o.order_time))/60),2) AS avg_delivery_time_minutes FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id WHERE o.status = 'Delivered' GROUP BY r.city ORDER BY avg_delivery_time_minutes LIMIT 10;

--TOP 10 FASTEST DELIVERY PARTNER
SELECT dp.partner_id,dp.partner_name,ROUND(AVG(EXTRACT(EPOCH FROM (o.delivered_time - o.order_time))/60),2) AS avg_delivery_time_minutes FROM orders o
JOIN delivery_partners dp ON o.partner_id = dp.partner_id WHERE o.status = 'Delivered'
GROUP BY dp.partner_id, dp.partner_name
ORDER BY avg_delivery_time_minutes LIMIT 10;


--AVG Delays by each day
SELECT TO_CHAR(order_time, 'Day') AS weekday,ROUND(AVG( EXTRACT(EPOCH FROM (delivered_time - order_time))/60),2) AS avg_delay_minutes FROM orders
WHERE status = 'Delivered'
GROUP BY EXTRACT(DOW FROM order_time), TO_CHAR(order_time, 'Day') ORDER BY EXTRACT(DOW FROM order_time);


SELECT * FROM customers;
SELECT * FROM restaurants;

SELECT * FROM delivery_partners;

SELECT * FROM orders;

SELECT * FROM payments;

SELECT * FROM ratings;

SELECT * FROM customer_behaviour;
SELECT * FROM restaurants;

SELECT status FROM orders WHERE status = 'Cancelled';

--Which restaurants receive the highest volume of cancellations
SELECT r.restaurant_id,r.restaurant_name,count(*) AS count_res FROM orders o JOIN restaurants r ON o.restaurant_id = r.restaurant_id where o.status = 'Cancelled' 
GROUP BY r.restaurant_id,r.restaurant_name ORDER BY count_res DESC;

--Which cities have the highest cancellation rates by percentage
SELECT r.city,count(CASE WHEN o.status = 'Cancelled' THEN 1 END) AS Cancelled_orders,COUNT(*) AS total_orders,
(COUNT(*)-count(CASE WHEN o.status = 'Cancelled' THEN 1 END)) as cancelled_orders,
ROUND(count(CASE WHEN o.status = 'Cancelled' THEN 1 END)*100/count(*),2) AS cancellation_per FROM orders o JOIN restaurants r ON o.restaurant_id = r.restaurant_id  
GROUP BY r.city ORDER BY cancellation_per DESC;

--Is there a correlation between delivery delays and cancellations
SELECT r.restaurant_name,ROUND(AVG(EXTRACT(EPOCH FROM (o.delivered_time - o.order_time))/60),2) AS avg_delivery_delay,
SUM(CASE WHEN o.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders
FROM orders o JOIN restaurants r ON o.restaurant_id = r.restaurant_id GROUP BY r.restaurant_name ORDER BY cancelled_orders DESC;

--On which days and at which times do cancellations peak
SELECT TO_CHAR(order_time, 'Day') AS weekday,EXTRACT(HOUR FROM order_time) AS hour_of_day,COUNT(*) AS cancelled_orders
FROM orders WHERE status = 'Cancelled' GROUP BY TO_CHAR(order_time, 'Day'),EXTRACT(HOUR FROM order_time)
ORDER BY cancelled_orders DESC;

--which customer having higest cancellation percentage
SELECT c.customer_id,c.customer_name,count(CASE WHEN o.status = 'Cancelled' THEN 1 END) AS Cancelled_orders, COUNT(*) AS toal_orders,
ROUND(count(CASE WHEN o.status = 'Cancelled' THEN 1 END)*100/count(*),2) AS cancellation_per
FROM orders o JOIN customers c ON o.customer_id = c.customer_id GROUP BY c.customer_id,c.customer_name ORDER BY cancellation_per DESC;

--which partner having higest cancellation percentage
SELECT dp.partner_id,dp.partner_name,count(CASE WHEN o.status = 'Cancelled' THEN 1 END) AS Cancelled_orders, COUNT(*) AS toal_orders,
ROUND(count(CASE WHEN o.status = 'Cancelled' THEN 1 END)*100/count(*),2) AS cancellation_per
FROM orders o JOIN delivery_partners dp ON o.partner_id = dp.partner_id GROUP BY dp.partner_id,dp.partner_name ORDER BY cancellation_per DESC;

--top 100 customer having lowst cancellation per
SELECT c.customer_id,c.customer_name,count(CASE WHEN o.status = 'Cancelled' THEN 1 END) AS Cancelled_orders, COUNT(*) AS toal_orders,
ROUND(count(CASE WHEN o.status = 'Cancelled' THEN 1 END)*100/count(*),2) AS cancellation_per
FROM orders o JOIN customers c ON o.customer_id = c.customer_id GROUP BY c.customer_id,c.customer_name ORDER BY cancellation_per LIMIT 100;

--TOP 10 parners having lowest cancellation per
SELECT dp.partner_id,dp.partner_name,count(CASE WHEN o.status = 'Cancelled' THEN 1 END) AS Cancelled_orders, COUNT(*) AS toal_orders,
ROUND(count(CASE WHEN o.status = 'Cancelled' THEN 1 END)*100/count(*),2) AS cancellation_per
FROM orders o JOIN delivery_partners dp ON o.partner_id = dp.partner_id GROUP BY dp.partner_id,dp.partner_name ORDER BY cancellation_per LIMIT 20;

--Estimated Revenue Lost Due to Cancellations
SELECT ROUND(SUM(order_amount),2) AS revenue_lost FROM orders WHERE status = 'Cancelled';

--Estimated Revenue Lost Due to Cancellations BY EACH restaurant
SELECT restaurant_id, ROUND(SUM(order_amount),2) AS revenue_lost FROM orders WHERE status = 'Cancelled' GROUP BY restaurant_id ORDER BY revenue_lost DESC;

--Which restaurants generate the highest total revenue
SELECT r.restaurant_id ,r.restaurant_name, ROUND(SUM(order_amount),2) AS revenue_generated FROM orders o JOIN restaurants r
ON r.restaurant_id = o.restaurant_id WHERE o.status = 'Delivered' GROUP BY r.restaurant_id,r.restaurant_name ORDER BY revenue_generated DESC;

--Which cities contribute the most to overall company revenue
SELECT r.city, ROUND(SUM(order_amount),2) AS revenue_generated FROM orders o JOIN restaurants r
ON r.restaurant_id = o.restaurant_id WHERE o.status = 'Delivered' GROUP BY r.city ORDER BY revenue_generated DESC;

--i need monthly revanue of each city
SELECT r.city, TO_CHAR(o.order_time, 'YYYY-MM') AS month, ROUND(SUM(o.order_amount),2) AS monthly_revenue
FROM orders o JOIN restaurants r ON o.restaurant_id = r.restaurant_id WHERE o.status = 'Delivered'
GROUP BY r.city,TO_CHAR(o.order_time, 'YYYY-MM') ORDER BY r.city,month;

SELECT * FROM customers;
SELECT * FROM restaurants;

SELECT * FROM delivery_partners;

SELECT * FROM orders;

SELECT * FROM payments;

SELECT * FROM ratings;

SELECT * FROM customer_behaviour;
SELECT * FROM restaurants;

--Which payment methods are most popular and most valuable
SELECT p.payment_mode,COUNT(*) AS total_count_mode FROM orders o join payments p ON o.order_id = p.order_id 
GROUP BY p.payment_mode ORDER BY total_count_mode DESC;

--What are the monthly revenue trends over the past year
SELECT TO_CHAR(order_time, 'YYYY-MM') AS month,ROUND(SUM(order_amount),2) AS monthly_revenue
FROM orders WHERE status = 'Delivered' GROUP BY TO_CHAR(order_time, 'YYYY-MM') ORDER BY month;

--Month-over-Month Revenue Change	
WITH monthly_revenue AS
(SELECT TO_CHAR(order_time,'YYYY-MM') AS month,ROUND(SUM(order_amount),2) AS revenue FROM orders WHERE status = 'Delivered'
GROUP BY TO_CHAR(order_time,'YYYY-MM')
)
SELECT month,revenue,revenue - LAG(revenue) OVER(ORDER BY month) AS revenue_change
FROM monthly_revenue ORDER BY month;

--Top 10 cities with lowest revenue
SELECT r.city, ROUND(SUM(order_amount),2) AS revenue_generated FROM orders o JOIN restaurants r
ON r.restaurant_id = o.restaurant_id WHERE o.status = 'Delivered' GROUP BY r.city ORDER BY revenue_generated LIMIT 10;

--Revenue by cuisine
SELECT r.cuisine_type, ROUND(SUM(order_amount),2) AS revenue_generated FROM orders o JOIN restaurants r
ON r.restaurant_id = o.restaurant_id WHERE o.status = 'Delivered' GROUP BY r.cuisine_type ORDER BY revenue_generated DESC;

--Who are the top 10 most valuable customers by lifetime spending
SELECT c.customer_id, c.customer_name, ROUND(AVG(cb.total_spending),2) AS avg_customer_value FROM customers c JOIN customer_behaviour cb ON c.customer_id = cb.customer_id
GROUP BY c.customer_id, c.customer_name ORDER BY avg_customer_value DESC LIMIT 10;

--Which customers order most frequently, and what is their average order value?
SELECT c.customer_id,c.customer_name, COUNT(o.order_id) AS total_orders,ROUND(AVG(o.order_amount),2) AS avg_order_value
FROM customers c JOIN orders o ON c.customer_id = o.customer_id WHERE o.status = 'Delivered'
GROUP BY c.customer_id, c.customer_name ORDER BY total_orders DESC;

--Which customers have gone inactive in the last 90 days

SELECT customer_id,last_order_days FROM customer_behaviour WHERE last_order_days > 90;

--Customers With Declining Spending
SELECT c.customer_id,c.customer_name,cb.total_spending,cb.avg_order_value
FROM customers c JOIN customer_behaviour cb ON c.customer_id = cb.customer_id ORDER BY cb.total_spending;

--Analyze Existing Churned Customers
SELECT
    ROUND(AVG(total_orders),2) AS avg_orders,
    ROUND(AVG(total_spending),2) AS avg_spending,
    ROUND(AVG(avg_order_value),2) AS avg_order_value,
    ROUND(AVG(last_order_days),2) AS avg_days_since_last_order
FROM customer_behaviour
WHERE churn_flag = TRUE;

--High-Risk Customers
SELECT
    c.customer_id,
    c.customer_name,
    cb.total_orders,
    cb.total_spending,
    cb.last_order_days
FROM customers c
JOIN customer_behaviour cb
ON c.customer_id = cb.customer_id
WHERE cb.last_order_days > 30
  AND cb.total_orders < 5
ORDER BY cb.last_order_days DESC;

--New customers per month
SELECT TO_CHAR(signup_date, 'YYYY-MM') AS month,COUNT(customer_id) AS new_customers
FROM customers GROUP BY TO_CHAR(signup_date, 'YYYY-MM') ORDER BY month;

--Segment Customers by Spending
SELECT customer_id, total_spending,
    CASE
        WHEN total_spending >= 10000 THEN 'High Value'
        WHEN total_spending >= 5000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM customer_behaviour;

SELECT * FROM customers;
SELECT * FROM restaurants;

SELECT * FROM delivery_partners;

SELECT * FROM orders;

SELECT * FROM payments;

SELECT * FROM ratings;

SELECT * FROM customer_behaviour;
SELECT * FROM restaurants;

--Which partners handle the highest volume of successful deliveries
SELECT dp.partner_id,dp.partner_name,COUNT(o.order_id) AS count_orders FROM orders o join delivery_partners dp ON o.partner_id = dp.partner_id
WHERE o.status = 'Delivered'
GROUP BY dp.partner_id,dp.partner_name ORDER BY count_orders DESC; 	

--What is the average customer rating received per delivery partner
SELECT o.partner_id, ROUND(AVG(r.customer_rating),2) as avg_rating FROM orders o Join ratings r ON o.order_id = r.order_id 
GROUP BY o.partner_id ORDER BY avg_rating DESC;

--partner ranking as per average customer rating
SELECT dp.partner_id,dp.partner_name,ROUND(AVG(r.customer_rating), 2) AS avg_rating,DENSE_RANK() OVER (ORDER BY AVG(r.customer_rating) DESC) AS partner_rank
FROM delivery_partners dp JOIN orders o ON dp.partner_id = o.partner_id JOIN ratings r ON o.order_id = r.order_id
GROUP BY dp.partner_id,dp.partner_name ORDER BY partner_rank;

----partner ranking as per successful deliveries 
SELECT dp.partner_id, dp.partner_name,COUNT(o.order_id) AS successful_deliveries,DENSE_RANK() OVER (ORDER BY COUNT(o.order_id) DESC) AS partner_rank
FROM orders o JOIN delivery_partners dp ON o.partner_id = dp.partner_id WHERE o.status = 'Delivered'
GROUP BY dp.partner_id, dp.partner_name;

--Average Delivery Time by Partner (SLA Performance)
SELECT dp.partner_id, dp.partner_name, ROUND(AVG(EXTRACT(EPOCH FROM (o.delivered_time - o.order_time))/60),2) AS avg_delivery_time
FROM delivery_partners dp JOIN orders o ON dp.partner_id = o.partner_id WHERE o.status = 'Delivered' GROUP BY dp.partner_id, dp.partner_name 
ORDER BY avg_delivery_time;


--Delivery partner with above the higest avg delay time
SELECT dp.partner_id,dp.partner_name,ROUND(AVG(EXTRACT(EPOCH FROM (o.delivered_time - o.order_time))/60),2) AS avg_time FROM delivery_partners dp
JOIN orders o ON dp.partner_id = o.partner_id WHERE o.status = 'Delivered' GROUP BY dp.partner_id,dp.partner_name 
HAVING ROUND(AVG(EXTRACT(EPOCH FROM (o.delivered_time - o.order_time))/60),2) > 
(SELECT ROUND(AVG(EXTRACT(EPOCH FROM (delivered_time - order_time))/60),2) AS avg_time FROM orders);


