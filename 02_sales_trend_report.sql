WITH quarterly_summary AS (
    SELECT
        c.customer_id,
        c.company_name,
        DATE_TRUNC('quarter', o.order_date) AS order_quarter,
        SUM(o.net_amount) AS quarterly_revenue,
        COUNT(o.order_id) AS total_orders,
        LAG(SUM(o.net_amount), 1) OVER (
            PARTITION BY c.customer_id 
            ORDER BY DATE_TRUNC('quarter', o.order_date) ASC
        ) AS previous_quarter_revenue
		
    FROM customers c
    INNER JOIN orders o 
        ON c.customer_id = o.customer_id
		
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
    CASE
        WHEN previous_quarter_revenue IS NULL THEN 'New Period'
        WHEN quarterly_revenue < previous_quarter_revenue THEN 'Decline'
        ELSE 'Growth or Stable'
    END AS revenue_trend
	
FROM quarterly_summary
ORDER BY 
    company_name ASC, 
    order_quarter ASC;