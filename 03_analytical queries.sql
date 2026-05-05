-- ============================================================
-- TCC Goat Whey · Analytical Queries
-- These are the queries that power the Tableau dashboard
-- Run AFTER 01_schema.sql + 02_seed_data.sql
-- ============================================================


-- ────────────────────────────────────────────────────────────
-- Q1 · Monthly Revenue & Profit Summary  (KPI Table)
-- ────────────────────────────────────────────────────────────
SELECT
    DATE_TRUNC('month', o.order_date)           AS month,
    COUNT(o.order_id)                            AS total_orders,
    COUNT(DISTINCT o.customer_id)                AS unique_customers,
    SUM(o.revenue)                               AS gross_revenue,
    SUM(o.cogs_total)                            AS total_cogs,
    SUM(o.platform_fee)                          AS total_platform_fees,
    COALESCE(SUM(ads.spend_amount), 0)           AS total_ad_spend,
    SUM(o.revenue)
      - SUM(o.cogs_total)
      - SUM(o.platform_fee)
      - COALESCE(SUM(ads.spend_amount), 0)       AS net_profit,
    ROUND(
      (SUM(o.revenue)
      - SUM(o.cogs_total)
      - SUM(o.platform_fee)
      - COALESCE(SUM(ads.spend_amount), 0))
      / NULLIF(SUM(o.revenue), 0) * 100, 2
    )                                             AS net_margin_pct,
    ROUND(SUM(o.revenue)
      / NULLIF(SUM(ads.spend_amount), 0), 2)     AS roas
FROM fact_orders o
LEFT JOIN (
    SELECT spend_month, SUM(spend_amount) AS spend_amount
    FROM fact_ad_spend
    GROUP BY spend_month
) ads ON DATE_TRUNC('month', o.order_date) = ads.spend_month
GROUP BY 1
ORDER BY 1;


-- ────────────────────────────────────────────────────────────
-- Q2 · Channel Performance Breakdown  (Bar / Pie Chart)
-- ────────────────────────────────────────────────────────────
SELECT
    c.channel_name,
    c.channel_type,
    COUNT(o.order_id)                            AS orders,
    SUM(o.revenue)                               AS revenue,
    SUM(o.platform_fee)                          AS fees_paid,
    ROUND(SUM(o.platform_fee) / NULLIF(SUM(o.revenue), 0) * 100, 1)
                                                  AS effective_fee_pct,
    ROUND(SUM(o.revenue - o.cogs_total - o.platform_fee)
          / NULLIF(SUM(o.revenue), 0) * 100, 1)  AS channel_margin_pct
FROM fact_orders o
JOIN dim_channel c ON o.channel_id = c.channel_id
GROUP BY c.channel_name, c.channel_type
ORDER BY revenue DESC;


-- ────────────────────────────────────────────────────────────
-- Q3 · Customer Acquisition vs Retention  (Stacked Bar)
-- ────────────────────────────────────────────────────────────
SELECT
    DATE_TRUNC('month', o.order_date)            AS month,
    SUM(CASE WHEN o.is_repeat_order = FALSE THEN 1 ELSE 0 END) AS new_customers,
    SUM(CASE WHEN o.is_repeat_order = TRUE  THEN 1 ELSE 0 END) AS repeat_customers,
    COUNT(o.order_id)                            AS total_orders,
    ROUND(
      SUM(CASE WHEN o.is_repeat_order = TRUE THEN 1 ELSE 0 END)::NUMERIC
      / NULLIF(COUNT(o.order_id), 0) * 100, 1
    )                                             AS retention_rate_pct
FROM fact_orders o
GROUP BY 1
ORDER BY 1;


-- ────────────────────────────────────────────────────────────
-- Q4 · CAC & ROAS by Month  (Dual-Axis Line Chart)
-- ────────────────────────────────────────────────────────────
SELECT
    ads.spend_month                               AS month,
    SUM(ads.spend_amount)                        AS total_spend,
    SUM(ads.new_customers_acquired)              AS customers_acquired,
    ROUND(
      SUM(ads.spend_amount)
      / NULLIF(SUM(ads.new_customers_acquired), 0), 0
    )                                             AS cac,
    ROUND(SUM(o.revenue) / NULLIF(SUM(ads.spend_amount), 0), 2)
                                                  AS roas
FROM fact_ad_spend ads
LEFT JOIN fact_orders o
  ON DATE_TRUNC('month', o.order_date) = ads.spend_month
GROUP BY ads.spend_month
ORDER BY ads.spend_month;


-- ────────────────────────────────────────────────────────────
-- Q5 · Product Mix Revenue  (Treemap / Donut)
-- ────────────────────────────────────────────────────────────
SELECT
    p.variant,
    p.mrp,
    p.cogs_per_unit,
    ROUND(p.gross_margin * 100, 1)               AS gross_margin_pct,
    COUNT(o.order_id)                            AS units_sold,
    SUM(o.revenue)                               AS total_revenue,
    SUM(o.revenue - o.cogs_total)                AS total_gross_profit
FROM fact_orders o
JOIN dim_product p ON o.product_id = p.product_id
GROUP BY p.variant, p.mrp, p.cogs_per_unit, p.gross_margin
ORDER BY total_revenue DESC;


-- ────────────────────────────────────────────────────────────
-- Q6 · Customer Persona Segmentation  (Heat Map)
-- ────────────────────────────────────────────────────────────
SELECT
    dc.persona,
    dc.age_band,
    dc.city_tier,
    COUNT(DISTINCT o.customer_id)                AS customers,
    COUNT(o.order_id)                            AS orders,
    ROUND(SUM(o.revenue) / NULLIF(COUNT(DISTINCT o.customer_id), 0), 0)
                                                  AS avg_ltv,
    ROUND(COUNT(o.order_id)::NUMERIC
          / NULLIF(COUNT(DISTINCT o.customer_id), 0), 2)
                                                  AS orders_per_customer
FROM fact_orders o
JOIN dim_customer dc ON o.customer_id = dc.customer_id
GROUP BY dc.persona, dc.age_band, dc.city_tier
ORDER BY avg_ltv DESC;


-- ────────────────────────────────────────────────────────────
-- Q7 · Break-even ROAS Analysis  (Reference Line)
-- Shows TCC advantage vs generic brand at same price point
-- ────────────────────────────────────────────────────────────
WITH margin_calc AS (
  SELECT
    p.variant,
    p.mrp,
    p.cogs_per_unit                              AS tcc_cogs,
    p.mrp * 0.90                                 AS competitor_cogs,  -- industry standard
    (p.mrp - p.cogs_per_unit) / p.mrp            AS tcc_gross_margin,
    (p.mrp - p.mrp * 0.90) / p.mrp              AS comp_gross_margin,
    c.platform_fee_rate
  FROM dim_product p
  CROSS JOIN dim_channel c
  WHERE c.channel_name IN ('Amazon', 'Blinkit')
)
SELECT
  variant,
  channel_name,      -- requires join fix below — kept clean for readability
  mrp,
  ROUND(tcc_gross_margin * 100, 1)              AS tcc_margin_pct,
  ROUND(comp_gross_margin * 100, 1)             AS competitor_margin_pct,
  ROUND(1 / NULLIF(tcc_gross_margin - platform_fee_rate, 0), 2)
                                                 AS tcc_breakeven_roas,
  ROUND(1 / NULLIF(comp_gross_margin - platform_fee_rate, 0), 2)
                                                 AS competitor_breakeven_roas
FROM margin_calc
JOIN dim_channel c2 ON margin_calc.platform_fee_rate = c2.platform_fee_rate
WHERE c2.channel_name IN ('Amazon', 'Blinkit')
ORDER BY variant, channel_name;
