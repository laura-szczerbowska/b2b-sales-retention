# B2B Sales Retention & Trend Analysis (SQL Case Study)
> **Note on Data:** All customer records, order volumes, and financial figures used in this project are strictly synthetic (mock data) generated for analytical demonstration purposes.

<br>

## Business Context
In B2B business models, identifying early signals of revenue contraction among Key Accounts is critical for proactive churn prevention. This project delivers an automated SQL-based reporting model designed for ERP databases to track quarter-over-quarter performance and categorize account trajectory.

---

## Tech Stack & Analytical Patterns
* **Common Table Expressions** (CTE): Isolates data aggregation from business classification logic.
* **Temporal Aggregation** (`DATE_TRUNC`): Normalizes transactional timestamps into quarterly buckets.
* **Window Functions** (`LAG`): Retrieves prior-period revenue partitioned by customer without self-joins.
* **Conditional Logic** (`CASE WHEN`): Automates account performance labeling (`New Period`, `Decline`, `Growth or Stable`).

---

## Query Results Preview

| company_name | order_quarter | total_orders | quarterly_revenue | previous_quarter_revenue | revenue_trend |
| :--- | :---: | :---: | :---: | :---: | :--- |
| Apex Solutions Ltd | 2026-01-01 | 2 | $120,000.00 | *NULL* | `New Period` |
| Apex Solutions Ltd| 2026-04-01 | 1 | $50,000.00 | $120,000.00 | `Decline` |
| Vanguard Retail Inc | 2026-01-01 | 1 | $25,000.00 | *NULL* | `New Period` |
| Vanguard Retail Inc | 2026-04-01 | 1 | $70,000.00 | $25,000.00 | `Growth or Stable` |

---

## Business Recommendations
1. **At-Risk Account Flagged:** Apex Solutions Ltd experienced a 58.3% QoQ revenue drop in Q2. An automated notification can be routed to the Key Account Director for an immediate retention review.
2. **BI Consumption Layer:** This SQL query can serve directly as a database view for Power BI / Tableau dashboards, removing the need for heavy DAX/calculated columns.
