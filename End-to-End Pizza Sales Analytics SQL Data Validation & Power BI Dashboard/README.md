# End-to-End Pizza Sales Analytics (SQL & Power BI)

## Project Overview

In this project, I built an end-to-end data analytics and business intelligence solution to analyze one year of sales performance for a pizza restaurant chain. Working with a dataset of over 48,000 transaction records from 2015, I extracted insights on revenue trends, customer ordering habits, and menu item profitability.

To ensure complete accuracy in my reporting, I used a **two-way data validation approach**:
1. I imported the raw data into **MS SQL Server** and wrote custom SQL queries to calculate key business metrics and trend benchmarks directly from the database.
2. I built an interactive dashboard in **Power BI Desktop**, writing explicit DAX measures for each metric.
3. I cross-checked every Power BI output against my SQL query results to verify 100% data alignment before finalizing the dashboard.

---

## Tech Stack & Tools

* **Database Engine**: MS SQL Server & SQL Server Management Studio (SSMS v19.0)
* **Data Visualization**: Microsoft Power BI Desktop (June 2023 Update)
* **Data Transformation**: Power Query (M Language)
* **Data Modeling & Calculations**: Data Analysis Expressions (DAX)
* **Spreadsheet & Raw Data**: MS Excel / Flat CSV (`pizza_sales.csv`)

---

## Dataset Schema & Data Dictionary

The dataset consists of a single flat file, `pizza_sales.csv`, containing **48,620 line-item transactions** across **12 columns** covering the entire 2015 calendar year.

| Column Name | SQL Data Type | Key Type | Description |
| :--- | :--- | :--- | :--- |
| `pizza_id` | `INT` | Primary Key | Unique ID for each pizza sold in a line item. |
| `order_id` | `INT` | Foreign Key | Transaction ID (repeats across rows when an order includes multiple pizzas). |
| `pizza_name_id` | `VARCHAR(50)` | Categorical Code | Short standardized text code for the pizza item. |
| `quantity` | `TINYINT` | Numeric Volume | Quantity of pizzas ordered per line item. |
| `order_date` | `DATE` | Temporal Date | Date the order was placed. |
| `order_time` | `TIME` | Temporal Time | Exact timestamp when the order was placed. |
| `unit_price` | `DECIMAL(10,2)` | Currency | Price per individual pizza. |
| `total_price` | `DECIMAL(10,2)` | Currency | Total price for the line item ($\text{quantity} \times \text{unit\_price}$). |
| `pizza_size` | `VARCHAR(50)` | Categorical Size | Size code ($S$, $M$, $L$, $XL$, $XXL$). |
| `pizza_category` | `VARCHAR(50)` | Menu Group | Category (*Classic*, *Supreme*, *Chicken*, *Veggie*). |
| `pizza_ingredients` | `VARCHAR(200)` | Text Field | Ingredients and topping details. |
| `pizza_name` | `VARCHAR(50)` | Item Name | Official commercial name of the pizza. |

---

## Key Performance Indicators (KPIs) & Math Logic

I structured the analysis around five core KPIs to measure overall business performance:

1. **Total Revenue**: Total dollar amount generated across all orders.
   $$\text{Total Revenue} = \sum (\text{total\_price})$$
2. **Average Order Value (AOV)**: Average amount spent per customer order.
   $$\text{Average Order Value} = \frac{\sum (\text{total\_price})}{\text{COUNT(DISTINCT order\_id)}}$$
3. **Total Pizzas Sold**: Total physical volume of pizzas sold.
   $$\text{Total Pizzas Sold} = \sum (\text{quantity})$$
4. **Total Orders**: Count of unique customer orders processed.
   $$\text{Total Orders} = \text{COUNT(DISTINCT order\_id)}$$
5. **Average Pizzas Per Order**: Average number of pizzas purchased per order transaction.
   $$\text{Average Pizzas Per Order} = \frac{\sum (\text{quantity})}{\text{COUNT(DISTINCT order\_id)}}$$

---

## SQL Data Engineering & Query Implementation

### 1. Database Creation & Data Type Tuning
I created a database named `PizzaDB` in SQL Server and imported `pizza_sales.csv`. During import, I adjusted several default data types to ensure data integrity and avoid runtime errors:
* Changed `pizza_id` and `order_id` to `INT` to accommodate 48,000+ records.
* Set `quantity` to `TINYINT`.
* Set `unit_price` and `total_price` to `DECIMAL(10,2)`.
* Expanded `pizza_ingredients` to `VARCHAR(200)` so long topping descriptions wouldn't get truncated.

### 2. SQL Queries Executed

#### Core KPI Queries
```sql
-- 1. Total Revenue
SELECT SUM(total_price) AS Total_Revenue 
FROM pizza_sales;
-- Output: $817,860.05

-- 2. Average Order Value (AOV)
SELECT SUM(total_price) / COUNT(DISTINCT order_id) AS Avg_Order_Value 
FROM pizza_sales;
-- Output: $38.30

-- 3. Total Pizzas Sold
SELECT SUM(quantity) AS Total_Pizza_Sold 
FROM pizza_sales;
-- Output: 49,574

-- 4. Total Orders
SELECT COUNT(DISTINCT order_id) AS Total_Orders 
FROM pizza_sales;
-- Output: 21,350

-- 5. Average Pizzas Per Order
SELECT CAST(CAST(SUM(quantity) AS DECIMAL(10,2)) / 
            CAST(COUNT(DISTINCT order_id) AS DECIMAL(10,2)) AS DECIMAL(10,2)) 
            AS Avg_Pizzas_Per_Order
FROM pizza_sales;
-- Output: 2.32
```

#### Trend & Category Breakdowns
```sql
-- Daily Order Trend (Orders by Day of Week)
SELECT DATENAME(DW, order_date) AS order_day, 
       COUNT(DISTINCT order_id) AS total_orders
FROM pizza_sales
GROUP BY DATENAME(DW, order_date);

-- Monthly Order Trend (Ranked by Volume)
SELECT DATENAME(MONTH, order_date) AS month_name, 
       COUNT(DISTINCT order_id) AS total_orders
FROM pizza_sales
GROUP BY DATENAME(MONTH, order_date)
ORDER BY total_orders DESC;

-- Percentage of Sales by Pizza Category
SELECT pizza_category, 
       CAST(SUM(total_price) AS DECIMAL(10,2)) AS total_revenue,
       CAST(SUM(total_price) * 100 / (SELECT SUM(total_price) FROM pizza_sales) AS DECIMAL(10,2)) AS PCT
FROM pizza_sales
GROUP BY pizza_category;
```

#### Best & Worst Seller Queries
```sql
-- Top 5 Pizzas by Revenue
SELECT TOP 5 pizza_name, SUM(total_price) AS Total_Revenue
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Revenue DESC;

-- Bottom 5 Pizzas by Revenue
SELECT TOP 5 pizza_name, SUM(total_price) AS Total_Revenue
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Revenue ASC;

-- Top 5 Pizzas by Total Quantity Sold
SELECT TOP 5 pizza_name, SUM(quantity) AS Total_Quantity
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Quantity DESC;

-- Bottom 5 Pizzas by Total Orders
SELECT TOP 5 pizza_name, COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Orders ASC;
```

---

## Data Validation Results

To verify data consistency between my SQL database and my Power BI dashboard, I compared key metrics from both tools side-by-side:

| KPI Metric | SQL Query Output | Power BI Visual Output | Validation Status |
| :--- | :--- | :--- | :--- |
| **Total Revenue** | \$817,860.05 | \$817.86K | **100% Match** |
| **Average Order Value (AOV)** | \$38.30 | \$38.30 | **100% Match** |
| **Total Pizzas Sold** | 49,574 | 49,574 | **100% Match** |
| **Total Orders** | 21,350 | 21,350 | **100% Match** |
| **Average Pizzas Per Order** | 2.32 | 2.32 | **100% Match** |

---

## Power BI Dashboard & DAX Measures

### 1. Data Cleaning in Power Query
After connecting Power BI directly to SQL Server, I transformed the raw dataset to improve readability and chart functionality:
* Standardized size abbreviations ($S \rightarrow \text{Regular}$, $M \rightarrow \text{Medium}$, $L \rightarrow \text{Large}$, $XL \rightarrow \text{X-Large}$, $XXL \rightarrow \text{XX-Large}$).
* Extracted `Day Name` and `Month Name` from `order_date`.
* Created custom index columns (`Day Number` from 1 to 7 and `Month Number` from 1 to 12) to sort day and month names chronologically rather than alphabetically.

### 2. DAX Measures Created
I wrote explicit DAX measures to power all visuals and card cards:

```dax
// Total Revenue
Total Revenue = SUM(pizza_sales[total_price])

// Total Orders
Total Orders = DISTINCTCOUNT(pizza_sales[order_id])

// Average Order Value
Average Order Value = [Total Revenue] / [Total Orders]

// Total Pizzas Sold
Total Pizzas Sold = SUM(pizza_sales[quantity])

// Average Pizzas Per Order
Average Pizzas Per Order = [Total Pizzas Sold] / [Total Orders]
```

### 3. Dashboard Design & Layout
I designed a two-page report:

1. **Executive Summary Page**:
   * Top KPI summary bar built using Power BI's **New Card Visual** (featuring custom rounded corners, drop shadows, and visual icons).
   * Column chart for **Daily Order Trends** and line chart for **Monthly Trends**.
   * Donut charts displaying revenue share by **Category** and **Size**.
   * Funnel chart showing total volume by **Category**.
   * Interactive date sliders, category slicers, and cross-filtering enabled across all visuals.

2. **Best & Worst Sellers Page**:
   * Focused page highlighting top 5 and bottom 5 pizzas across **Revenue**, **Quantity**, and **Total Orders**.
   * Left-side navigation bar with buttons to switch smoothly between the Executive Summary and Best/Worst Seller pages.

---

## Key Findings & Business Recommendations

### Core Insights
* **Peak Days**: Orders peak significantly on **Friday and Saturday evenings**, with Thursday also showing strong demand. Sundays and Mondays record the lowest order counts.
* **Seasonal Demand**: Order volume peaks in **July** (2,135 orders) and **May** (2,135 orders), followed by **January** (1,845 orders). Orders dip during autumn, hitting a low in **October** (1,646 orders).
* **Category Breakdown**: The **Classic category** leads overall sales volume and revenue (\$220,053), closely followed by Supreme (\$208,197) and Chicken (\$195,919).
* **Size Breakdown**: **Large pizzas** generate almost half of total revenue (45.89% / \$375,318), followed by Medium pizzas (30.49% / \$249,382). Regular size accounts for 21.77%, while XL and XXL combined contribute less than 2%.
* **Top Performers**:
  * **Thai Chicken Pizza** brings in the highest revenue (\$43,434).
  * **Classic Deluxe Pizza** sells the highest quantity (2,453 pizzas across 2,329 orders).
* **Lowest Performer**:
  * **Brie Carre Pizza** generated the lowest revenue (\$11,588), selling only 490 units across 480 orders.

### Recommendations for Management
1. **Optimize Staffing & Supply Chains**: Increase kitchen staffing and inventory prep for Thursday through Saturday shifts and during summer peak months (May–July).
2. **Promote High-Margin Items**: Feature top revenue drivers like *Thai Chicken* and *Classic Deluxe* prominently in marketing campaigns and combo offers.
3. **Menu Rationalization**: Re-evaluate *The Brie Carre Pizza*. Consider running a targeted promotion, modifying the recipe, or removing it from the menu to streamline inventory costs.

---

## How to Run This Project Locally

### Prerequisites
* MS SQL Server Management Studio (SSMS v19.0+)
* Microsoft Power BI Desktop (June 2023 update or newer)

### Step 1: SQL Server Setup
1. Open SSMS and create a new database:
   ```sql
   CREATE DATABASE PizzaDB;
   ```
2. Import `pizza_sales.csv` into `PizzaDB` using the **Import Flat File** wizard.
3. Verify data types (`pizza_id` as `INT`, `order_id` as `INT`, `pizza_ingredients` as `VARCHAR(200)`).
4. Run the SQL scripts provided above to generate metrics and verify outputs.

### Step 2: Power BI Setup
1. Open Power BI Desktop and select **Get Data** $\rightarrow$ **SQL Server**.
2. Enter your SQL Server name and database (`PizzaDB`).
3. Select `pizza_sales` and load the table.
4. Verify the DAX measures and interact with the dashboards.
