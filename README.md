#  E-Commerce Funnel, Cohort & Marketing Analytics Project

## Project Overview

This project is an **end-to-end e-commerce analytics case study** designed to simulate how a data analyst works with real business data — from data creation and transformation to insight-driven dashboards.

The objective was to analyze **user behavior, conversion funnels, retention patterns, customer lifetime value, and marketing performance**, and translate these analyses into actionable business insights.

The project follows a realistic analytics workflow:

**Python → SQL → Power BI**

---

## Business Questions Addressed

1. Where do users drop off most in the purchase funnel?
2. How effective is the Add-to-Cart and overall conversion process?
3. How well does the business retain users over time?
4. Which customer segments generate the most value and revenue?
5. Which marketing channels deliver the highest ROAS and conversion efficiency?

---

## Tech Stack

* **Python** – Simulated realistic e-commerce datasets (users, sessions, orders, marketing spend)
* **SQL (MySQL)** – Data modeling, transformations, and advanced analytics using window functions
* **Power BI** – Interactive dashboards, KPIs, cohort heatmaps, and business storytelling

---

## Data Model

The project uses a relational data model including:

* `users` – user signup details
* `sessions` – user sessions with device and UTM source
* `add_to_cart` – add-to-cart events
* `orders` – completed purchases and revenue
* `marketing` – channel-level ad spend
* `products` & `stock_out` – additional tables reserved for future scope

> **Note:** Product category and stock-out data were intentionally excluded from the current dashboards to keep the analysis focused on user behavior, retention, and marketing efficiency. These tables are documented as future enhancement opportunities.

---

## Dashboards & Analysis

### 1️⃣ User Funnel & Conversion Performance

**Focus:** Sessions → Add to Cart → Orders

**Key Metrics:**

* Total Sessions
* Add-to-Cart Sessions
* Orders
* Revenue
* Add-to-Cart Rate
* Overall Conversion Rate

**Insights:**

* The largest user drop-off occurs between **Sessions → Add to Cart**.
* Improving product discovery, site speed, or PDP UX (Product Detail Page User Experience) could significantly increase conversion.
* Funnel trends and conversion rates are tracked monthly to identify performance changes.

---

### 2️⃣ Cohort & Retention Analysis

**Focus:** User retention by signup cohort

**Techniques Used:**

* SQL window functions
* First-purchase cohort identification
* Month-over-month retention calculation

**Insights:**

* Retention drops sharply after **Month 1**, indicating early churn risk.
* Best-performing cohort identified using Month-1 retention.
* Customer base is growing, but low retention increases dependency on acquisition.

---

### 3️⃣ Customer Segmentation & Lifetime Value (LTV)

**Focus:** Customer value and behavior using RFM segmentation

**Segments Identified:**

* Champions
* Can’t Lose Them
* Loyal Customers

**Insights:**

* Champions contribute the highest share of revenue.
* “Can’t Lose Them” customers generate high revenue but show churn risk.
* Average LTV declines for newer cohorts, suggesting changing customer quality.

---

### 4️⃣ Marketing Attribution & Performance

**Focus:** Channel efficiency and ROI

**Key Metrics:**

* ROAS
* UTM Conversion Rate
* Cost per Order (CPO)

**Insights:**

* Organic Search delivers the **highest ROAS and conversion rate**.
* Paid Social has the highest spend but relatively lower efficiency.
* Marketing budget reallocation opportunities identified based on performance.

---

## SQL Techniques Used

* `COUNT() OVER (PARTITION BY …)` – cohort sizing and retention
* `MIN()` with grouping – cohort identification
* Multi-level CTEs for funnel and cohort analysis
* Aggregations for LTV, and repeat rate calculations
* Conditional logic for RFM segmentation

---

## Future Enhancements

* Category-level conversion and revenue analysis
* Stock-out impact on lost revenue and churn
* Inventory optimization dashboards
* Demand forecasting using historical sales trends

---

## Key Takeaways

* Demonstrates **end-to-end analytics workflow**
* Focuses on **business decision-making**, not just visualization
* Uses realistic data modeling and SQL logic

---

## 📌 Author Note

This project was built as a **portfolio case study for a Data Analyst (Fresher)** role, showcasing SQL, Python, and Power BI skills through real-world e-commerce scenarios.

## Attached dashboard images for reference

<img width="1163" height="662" alt="image" src="https://github.com/user-attachments/assets/079c4bc2-5876-4c0b-af1d-810552c52dec" />


<img width="1166" height="656" alt="image" src="https://github.com/user-attachments/assets/ad3ee47a-7d47-4b21-9a0c-2966562f037a" />


<img width="1175" height="652" alt="image" src="https://github.com/user-attachments/assets/243bfeb4-57a4-4bf5-8831-90e152d3509f" />


<img width="1138" height="638" alt="image" src="https://github.com/user-attachments/assets/d0e44743-7a06-4418-9d1b-88d45ad40966" />




