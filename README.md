# SQL-Project

# 🛒 Olist Brazilian E-Commerce SQL Project  
### Data Analytics Portfolio Project – Flor Hoyos

This project analyzes the Olist Brazilian E-Commerce dataset using **PostgreSQL** and **Tableau**.  
I built a complete relational database, validated the data, performed exploratory analysis, and generated business insights related to sales, customer behavior, delivery performance, and seller operations.

---

## 📂 Project Structure
---

## 🧱 1. Database Schema

All 9 Olist tables were recreated in PostgreSQL with correct data types and foreign key relationships:

- customers  
- orders  
- products  
- order_items  
- order_payments  
- order_reviews  
- geolocation  
- product_category_name_translation  
- sellers  

Schema file: [`schema.sql')

---

## 🔍 2. Data Validation

I checked:

- row counts per table  
- missing primary keys  
- duplicate IDs  
- orphan foreign keys (orders without customers, items without products, etc.)  
- unrealistic values (negative prices, invalid review scores)

Validation file: [`datavalidation.sql)

---

## 📊 3. Exploratory Analysis

High-level understanding of:

- customer distribution by state  
- monthly order volume  
- product categories  
- seller locations  
- review score distribution  
- delivery time averages (~12.6 days)

EDA file: ['exploratory_queries.sql`)

---

## 💡 4. Business Insights

Key insights uncovered:

### ⭐ Sales & Revenue
- Revenue and order volume trend upward month-to-month.  
- Some months show over **20% growth**.

### ⭐ Customer Behavior
- A significant portion of orders comes from **repeat customers**, indicating strong retention.  
- A few states generate disproportionately high revenue.

### ⭐ Product Insights
- The top 10 product categories drive the majority of total revenue.  
- Categories with the best reviews often correlate with lower delivery delays.

### ⭐ Delivery Performance
- **Average delivery time: 12.6 days**  
- Longer delivery delays correlate with **lower review scores**.

### ⭐ Seller Insights
- A small number of sellers account for most of the revenue (seller concentration).

Full insights file: (`businessinsights.sql`)

---

## 📈 5. Tableau Dashboard + Story

Built interactive dashboards answering:

1. **How do sales and revenue change over time?**  
2. **Which customer states generate the most revenue?**  
3. **What product categories dominate the marketplace?**  
4. **How does delivery performance affect customer satisfaction?**  
5. **Which sellers are the most valuable?**

---

## 🚀 Tools Used
- PostgreSQL
- pgAdmin 4
- SQL (joins, CTEs, windows, aggregations)
- Tableau Public
- GitHub for version control

---

## 👩🏻‍💻 Author  
Flor Hoyos  
Data Analyst | SQL · Tableau · Python  
