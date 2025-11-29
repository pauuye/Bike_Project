SELECT *
FROM sales;

SELECT *
FROM sales1;

-- Determining if there is a duplicate input/data by using Window Function ROW_Number and CTE
WITH dupli as (SELECT *, ROW_NUMBER() OVER(PARTITION BY `Date`, `Day`, `Month`, `Year`, Customer_Age, Age_Group, 
Customer_Gender, Country, State, Product_Category, Sub_Category, 
Product, Order_Quantity, Unit_Cost, Unit_Price, Profit, Cost, Revenue) as n_row
FROM sales)
SELECT *
FROM dupli
WHERE n_row > 1;

-- Creating another table similar to the raw data file 'sales' and inserting another column for the Row_Number. 
-- For deleting the duplicates and preserving the raw data file.
CREATE TABLE `sales1` (
  `Date` text,
  `Day` int DEFAULT NULL,
  `Month` text,
  `Year` int DEFAULT NULL,
  `Customer_Age` int DEFAULT NULL,
  `Age_Group` text,
  `Customer_Gender` text,
  `Country` text,
  `State` text,
  `Product_Category` text,
  `Sub_Category` text,
  `Product` text,
  `Order_Quantity` int DEFAULT NULL,
  `Unit_Cost` int DEFAULT NULL,
  `Unit_Price` int DEFAULT NULL,
  `Profit` int DEFAULT NULL,
  `Cost` int DEFAULT NULL,
  `Revenue` int DEFAULT NULL,
  `n_row` INT DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Inserting the data from 'sales' to 'sales1' + ROW_Number

INSERT INTO sales1
SELECT *, ROW_NUMBER() OVER(PARTITION BY `Date`, `Day`, `Month`, `Year`, Customer_Age, Age_Group, 
Customer_Gender, Country, State, Product_Category, Sub_Category, 
Product, Order_Quantity, Unit_Cost, Unit_Price, Profit, Cost, Revenue) as n_row
FROM sales;

-- Double checking if the insertion is accurate
-- Then deleting the duplicates.
-- Drop the column 'n_row' after the deletion process
SELECT *
FROM sales1
WHERE n_row >1;

DELETE
FROM sales1
WHERE n_row > 1;

ALTER TABLE sales1
DROP COLUMN n_row;

-- Exploratory Data Analysis

SELECT *
FROM sales1;

-- Determining the number of customer per age group
SELECT Age_Group, COUNT(Age_Group) as age_Count
FROM sales1
GROUP by Age_Group;

-- Determining the Top AVG Order Quantity by Year and By COuntry, 
-- By using CTE I can use the alias 'avg_Qty' for ordering in the Window Function
WITH avg_qty_D as(
SELECT `Year`, Country, ROUND(AVG(Order_Quantity),2) as avg_Qty
FROM Sales
WHERE Order_Quantity IS NOT NULL
GROUP BY `Year`, Country)
SELECT `Year`, Country, avg_Qty,
DENSE_RANK() OVER(PARTITION BY `Year` ORDER BY avg_Qty DESC) as c_rank
FROM avg_qty_D;

-- Profitable Categories
SELECT DISTINCT Product_Category, SUM(Profit)
FROM sales1
GROUP BY Product_Category;

-- Top 5 Sub_Categories by Average Revenue
SELECT DISTINCT Sub_Category, ROUND(AVG(Revenue),2) as Avg_rev
FROM sales1
GROUP BY Sub_Category
ORDER BY 2 DESC
LIMIT 5;

-- Top 5 Profitable Sub_Categories
SELECT DISTINCT Sub_Category, SUM(Profit) as Total_Profit
FROM sales1
GROUP BY Sub_Category
ORDER BY 2 DESC
LIMIT 10;

-- Most Profitable Products and Sub-Products(top5) by Year

-- Profitable Products by Year(2011-2016)
WITH t_prof1 as (
SELECT `Year`, Product_Category, SUM(Profit) as total_profit
FROM sales1
GROUP BY `Year`, Product_Category)
SELECT `Year`, Product_Category, total_profit,
DENSE_RANK() OVER(PARTITION BY `Year` ORDER BY total_profit DESC) as t_profit_rank
FROM t_prof1
;

-- Top 10 Profitable Sub-Products  by Year(2011-2016)
WITH t_prof2 as (
SELECT `Year`, Sub_Category, SUM(Profit) as sum_profit
FROM sales1
GROUP BY `Year`, Sub_Category),
ranked as (
SELECT `Year`,Sub_Category, sum_profit,
DENSE_RANK() OVER(PARTITION BY `Year` ORDER BY sum_profit DESC) as t_profit1_rank
FROM t_prof2
)
SELECT `Year`, Sub_Category, sum_profit, t_profit1_rank
FROM ranked
WHERE t_profit1_rank <= 10
ORDER BY `Year`, t_profit1_rank ASC;
-- STOP



-- Monthly Revenue RT
WITH monthly AS(
SELECT `Year`, MONTH(`Date`) AS month_num, -- For the months to be successive (January .... December) If only `Months` it will order by letters
`Month`, SUM(Revenue) AS monthly_revenue
FROM sales1
GROUP BY `Year`, month_num, `Month`
)
SELECT `Year`, `Month`, monthly_revenue,
SUM(monthly_revenue) OVER (PARTITION BY `Year` ORDER BY month_num) AS RevenueRT
FROM monthly
ORDER BY `Year`, month_num;

-- Average Order Quantity per Country
SELECT Country, ROUND(AVG(Order_Quantity),1) as avg_order
FROM sales1
GROUP BY Country
ORDER BY 2 DESC;


-- Average Order Quantity per Sub_Category
SELECT Sub_Category, ROUND(AVG(Order_Quantity),1) as avg_order
FROM sales1
GROUP BY Sub_Category
ORDER BY 2 DESC;

-- Group Age average order
SELECT Age_Group, ROUND(AVG(Order_Quantity),1) as AVG_order
FROM sales1
GROUP BY Age_Group
ORDER BY 2 DESC;











