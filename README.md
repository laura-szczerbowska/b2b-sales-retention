<div align="right">
  <strong>English</strong> | <a href="./README.pl.md">Polski</a>
</div>

# B2B Revenue Dynamics & Retention Analytics (SQL & Power BI)

> **Data Notice:** All transactional records, client names, and financial figures used across this project are synthetic and were generated strictly for demonstration and portfolio purposes.


<br>


## Business Context & Project Objectives

In B2B enterprise sales, systematic contraction in purchase volume rarely happens overnight. Early detection of decelerating quarterly trends enables Key Account Management to intervene proactively before an account fully churns to a competitor.

**Project Objective:**  
Develop an end-to-end analytical pipeline linking an ERP database directly to an interactive executive dashboard in Power BI. The solution aggregates transactions to quarterly intervals, tracks quarter-over-quarter (QoQ) revenue dynamics, and segments accounts by customer health and retention risk.


<br>


## Power BI Executive Dashboard

The report enables leadership to instantly detect high-risk accounts (*At Risk Accounts*) while tracking cross-sectional order volumes and quarterly revenue trajectories:


<br>


<img width="1375" height="776" alt="dashboard" src="https://github.com/user-attachments/assets/507f8846-2de2-4f08-829a-56b95d41bf38" />


<br>


### Key Dashboard Components:
- **Core KPI Cards:** High-level summary of total completed orders (15) and gross portfolio revenue (837.00k PLN).
- **"At Risk Accounts" KPI:** Critical alert indicator flagging accounts with declining revenue in the most recent period (2 accounts).
- **Line Chart (Quarterly Revenue Trend by Key Account):** Visualizing multi-directional revenue trajectories across FY2025 (Q1–Q4).
- **Bar Chart (Total Orders by Company):** Breakdown of total transaction engagement per account.
- **Status Matrix (Conditional Formatting):** Detailed account performance table featuring automated red highlights for the `Decline` status.
- **Interactive Slicer (Choose company name...):** Dynamic cross-filtering isolating specific client accounts.

<br>

## Architecture & SQL Analytical Layer

Following a *Database First* architecture, intensive time-series transformations and categorical status flagging were offloaded to the database engine, eliminating redundant DAX calculations and streamlining Power BI rendering performance.

### Applied SQL Techniques:
1. **Common Table Expressions (CTE):** Structured two-stage data transformation separating quarterly rollups from time-series window evaluation.
2. **Date Normalization (`DATE_TRUNC`):** Truncating discrete transaction timestamps to quarterly boundaries for reliable period-over-period comparisons.
3. **Window Functions (`LAG() OVER (...)`):** Efficiently retrieving the previous quarter's revenue per customer partition without expensive self-joins.
4. **Conditional Categorization (`CASE WHEN`):** Segmenting account health into actionable labels (`New Period`, `Decline`, `Growth or Stable`).


<br>


```sql
WITH quarterly_summary AS (
    SELECT
        c.customer_id,
        c.company_name,
-- Truncate order date to the first day of the quarter
        DATE_TRUNC('quarter', o.order_date) AS order_quarter,
        SUM(o.net_amount) AS quarterly_revenue,
        COUNT(o.order_id) AS total_orders,
-- Retrieve previous quarter revenue per account using a window function
        LAG(SUM(o.net_amount), 1) OVER (
            PARTITION BY c.customer_id 
            ORDER BY DATE_TRUNC('quarter', o.order_date) ASC
        ) AS previous_quarter_revenue
		
    FROM customers c
    INNER JOIN orders o 
        ON c.customer_id = o.customer_id
-- Filter for strategic accounts and completed transactions only
    WHERE c.segment ='Key Account'
      AND o.status = 'Completed'
    GROUP BY
        c.customer_id,
        c.company_name,
        DATE_TRUNC('quarter', o.order_date)
)
SELECT
    company_name,
    order_quarter,
    total_orders,
    quarterly_revenue,
    previous_quarter_revenue,
-- Classify revenue dynamics and flag retention churn risks
    CASE
        WHEN previous_quarter_revenue IS NULL THEN 'New Period'
        WHEN quarterly_revenue < previous_quarter_revenue THEN 'Decline'
        ELSE 'Growth or Stable'
    END AS revenue_trend
	
FROM quarterly_summary
ORDER BY 
    company_name ASC, 
    order_quarter ASC;
```

## Tabular Output Preview

The model evaluates a full financial year (FY2025) across 4 strategic B2B accounts:

| Company Name | Order Quarter | Total Orders | Quarterly Revenue | Previous Quarter Revenue | Revenue Trend |
| :--- | :---: | :---: | :---: | :---: | :--- |
| **Apex Solutions Ltd** | 2025-01-01 | 2 | 120,000.00 PLN | *NULL* | `New Period` |
| **Apex Solutions Ltd** | 2025-04-01 | 1 | 50,000.00 PLN | 120,000.00 PLN | `Decline` |
| **Apex Solutions Ltd** | 2025-07-01 | 1 | 30,000.00 PLN | 50,000.00 PLN | `Decline` |
| **Apex Solutions Ltd** | 2025-10-01 | 1 | 20,000.00 PLN | 30,000.00 PLN | `Decline` |
| **Vanguard Retail Inc** | 2025-01-01 | 1 | 25,000.00 PLN | *NULL* | `New Period` |
| **Vanguard Retail Inc** | 2025-04-01 | 1 | 70,000.00 PLN | 25,000.00 PLN | `Growth or Stable` |
| **Vanguard Retail Inc** | 2025-07-01 | 1 | 85,000.00 PLN | 70,000.00 PLN | `Growth or Stable` |
| **Vanguard Retail Inc** | 2025-10-01 | 1 | 110,000.00 PLN | 85,000.00 PLN | `Growth or Stable` |
| **Nordic Logistics AS** | 2025-01-01 | 1 | 60,000.00 PLN | *NULL* | `New Period` |
| **Nordic Logistics AS** | 2025-04-01 | 1 | 62,000.00 PLN | 60,000.00 PLN | `Growth or Stable` |
| **Nordic Logistics AS** | 2025-07-01 | 1 | 40,000.00 PLN | 62,000.00 PLN | `Decline` |
| **Nordic Logistics AS** | 2025-10-01 | 1 | 65,000.00 PLN | 40,000.00 PLN | `Growth or Stable` |
| **Syllable Tech Sp. z o.o.** | 2025-07-01 | 1 | 45,000.00 PLN | *NULL* | `New Period` |
| **Syllable Tech Sp. z o.o.** | 2025-10-01 | 1 | 55,000.00 PLN | 45,000.00 PLN | `Growth or Stable` |


<br>


## Analytical Insights & Prescriptive Business Actions

1. **Urgent Retention Alert – Case Study: Apex Solutions Ltd:**
   - Generated the portfolio's highest initial baseline in Q1 (120k PLN), followed by three consecutive quarterly declines: 50k $\to$ 30k $\to$ 20k PLN (-83.3% YoY total contraction).
   - **Recommendation:** Initiate an executive-level account review to investigate potential friction points (pricing pressure, operational SLA breaches, or competitor displacement).

<br>


<img width="1372" height="775" alt="dashboard1" src="https://github.com/user-attachments/assets/59b6427e-5c64-4fa5-8692-bbc3a54339cd" />



<br>


2. **Primary Revenue Engine (Vanguard Retail Inc):**
   - Scaled rapidly from 25k PLN in Q1 to 110k PLN in Q4 (+340% YoY expansion).
   - **Recommendation:** Transition the account into an enterprise loyalty tier and lock in a multi-year master service agreement (MSA).

3. **Seasonality vs. Normalization (Nordic Logistics AS):**
   - Experienced a temporary dip in Q3 (40k PLN), but fully rebounded in Q4 to 65k PLN.
   - **Recommendation:** Implement off-season volume incentives to bridge summer demand downturns.

4. **New Account Expansion (Syllable Tech Sp. z o.o.):**
   - Onboarded mid-year in Q3 (45k PLN) with immediate organic expansion in Q4 (55k PLN).
   - **Recommendation:** Deploy a cross-selling strategy targeting complementary product lines for the upcoming fiscal year.


<br>


## Getting Started

### Prerequisites:
- **Power BI Desktop** (free version).
- Optional: SQL Database client (pgAdmin) or a PostgreSQL database engine.

---

Clone the repository
```bash
git clone [https://github.com/laura-szczerbowska/b2b-revenue-retention-analysis.git](https://github.com/laura-szczerbowska/b2b-revenue-retention-analysis.git)
cd b2b-revenue-retention-analysis
```

Open the Power BI Dashboard
Open the file b2b_revenue_retention_dashboard.pbix directly in Power BI Desktop.
The report includes an embedded data model, providing immediate interactivity across slicers, cross-filtering, and dynamic tooltips.

Review the SQL Query
Open b2b_revenue_analysis.sql in any code editor or database client.
The script provides the complete end-to-end data pipeline, including CTEs, LAG() window functions, and CASE WHEN business logic.


<br>


## Technology Stack
* **Database & Query Language**: PostgreSQL (Window Functions, CTEs, Aggregations)
* **Business Intelligence & Visualization**: Power BI Desktop (b2b_revenue_retention_dashboard.pbix)
* **Data Modeling & Transformation**: SQL View / Power Query ETL
* **Version Control & Repository**: Git / GitHub
