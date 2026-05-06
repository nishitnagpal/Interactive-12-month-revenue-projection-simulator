-- ============================================================
-- TCC Goat Whey · Seed Data
-- Run AFTER 01_schema.sql
-- ============================================================

-- ── Channels
INSERT INTO dim_channel (channel_name, platform_fee_rate, channel_type) VALUES
  ('D2C',     0.10, 'd2c'),
  ('Amazon',  0.35, 'marketplace'),
  ('Blinkit', 0.38, 'quick_commerce'),
  ('Zepto',   0.38, 'quick_commerce');

-- ── Products
INSERT INTO dim_product (sku, product_name, variant, mrp, cogs_per_unit) VALUES
  ('TCC-GW-250',  'TCC Goat Whey Protein', '250g Trial',    999.00,  499.50),
  ('TCC-GW-500',  'TCC Goat Whey Protein', '500g Standard',1999.00,  899.55),
  ('TCC-GW-1KG',  'TCC Goat Whey Protein', '1kg Performance',3999.00,1599.60),
  ('TCC-GW-BNDL', 'TCC Goat Whey Bundle',  '2×500g + Shaker',4299.00,1934.55);

-- ── Customers (sample 50 — in real project, import from CRM export)
INSERT INTO dim_customer (acquisition_month, acquisition_channel_id, city_tier, age_band, persona)
SELECT
  DATE '2026-01-01' + (INTERVAL '1 month' * ((s - 1) / 5)),
  ((s - 1) % 4) + 1,
  CASE WHEN s % 3 = 0 THEN 'Tier1' WHEN s % 3 = 1 THEN 'Tier2' ELSE 'Tier1' END,
  CASE WHEN s % 4 = 0 THEN '25-34' WHEN s % 4 = 1 THEN '18-24'
       WHEN s % 4 = 2 THEN '35-44' ELSE '25-34' END,
  CASE WHEN s % 4 = 0 THEN 'Biohacker' WHEN s % 4 = 1 THEN 'Athlete'
       WHEN s % 4 = 2 THEN 'Wellness'  ELSE 'General' END
FROM generate_series(1, 60) AS s;

-- ── Orders (12 months, realistic growth curve)
INSERT INTO fact_orders
  (order_date, customer_id, channel_id, product_id, quantity,
   unit_price, discount_amt, cogs_total, platform_fee, is_repeat_order)
SELECT
  order_date,
  customer_id,
  channel_id,
  product_id,
  qty,
  unit_price,
  discount_amt,
  cogs_total,
  ROUND(unit_price * qty * fee_rate, 2),
  is_repeat
FROM (
  SELECT
    DATE '2026-01-15' + (INTERVAL '1 day' * (s % 28)) + (INTERVAL '1 month' * floor(s / 30)) AS order_date,
    (s % 60) + 1 AS customer_id,
    CASE WHEN s % 10 < 5 THEN 2         -- Amazon 50%
         WHEN s % 10 < 8 THEN 3         -- Blinkit 30%
         WHEN s % 10 < 9 THEN 4         -- Zepto 10%
         ELSE 1 END AS channel_id,       -- D2C 10%
    CASE WHEN s % 5 = 0 THEN 1
         WHEN s % 5 < 3 THEN 3
         ELSE 2 END AS product_id,
    1 AS qty,
    CASE WHEN s % 5 = 0 THEN 999.00
         WHEN s % 5 < 3  THEN 3999.00
         ELSE 1999.00 END AS unit_price,
    CASE WHEN s % 7 = 0 THEN 200.00 ELSE 0 END AS discount_amt,
    CASE WHEN s % 5 = 0 THEN 499.50
         WHEN s % 5 < 3  THEN 1599.60
         ELSE 899.55 END AS cogs_total,
    CASE WHEN s % 10 < 5 THEN 0.35
         WHEN s % 10 < 8 THEN 0.38
         WHEN s % 10 < 9 THEN 0.38
         ELSE 0.10 END AS fee_rate,
    (s > 30) AS is_repeat
  FROM generate_series(1, 360) AS s
) sub;

-- ── Ad Spend (monthly, 12 months)
INSERT INTO fact_ad_spend
  (spend_month, channel_id, campaign_type, spend_amount, impressions, clicks, new_customers_acquired)
VALUES
  -- Jan
  ('2026-01-01', 2, 'Brand_Awareness',  80000, 400000, 3200, 28),
  ('2026-01-01', 3, 'Conversion',        60000, 200000, 2800, 22),
  ('2026-01-01', 1, 'Retargeting',       30000,  80000, 1200,  8),
  -- Feb
  ('2026-02-01', 2, 'Brand_Awareness',  90000, 440000, 3520, 32),
  ('2026-02-01', 3, 'Conversion',        65000, 215000, 3010, 25),
  ('2026-02-01', 1, 'Retargeting',       35000,  90000, 1350, 10),
  -- Mar
  ('2026-03-01', 2, 'Brand_Awareness', 100000, 480000, 3840, 36),
  ('2026-03-01', 3, 'Conversion',        70000, 235000, 3290, 28),
  ('2026-03-01', 4, 'Conversion',        30000, 120000, 1680, 14),
  -- Q2
  ('2026-04-01', 2, 'Conversion',       110000, 520000, 4160, 42),
  ('2026-04-01', 3, 'Conversion',        75000, 255000, 3570, 30),
  ('2026-04-01', 1, 'Retargeting',       40000, 100000, 1500, 12),
  ('2026-05-01', 2, 'Conversion',       115000, 540000, 4320, 45),
  ('2026-05-01', 3, 'Retargeting',       80000, 270000, 3780, 33),
  ('2026-05-01', 4, 'Conversion',        35000, 130000, 1820, 16),
  ('2026-06-01', 2, 'Conversion',       120000, 560000, 4480, 48),
  ('2026-06-01', 3, 'Conversion',        85000, 285000, 3990, 35),
  ('2026-06-01', 1, 'Retargeting',       45000, 110000, 1650, 13),
  -- Q3
  ('2026-07-01', 2, 'Conversion',       130000, 600000, 4800, 52),
  ('2026-07-01', 3, 'Conversion',        90000, 305000, 4270, 38),
  ('2026-07-01', 4, 'Retargeting',       40000, 140000, 1960, 18),
  ('2026-08-01', 2, 'Conversion',       135000, 620000, 4960, 55),
  ('2026-08-01', 3, 'Conversion',        95000, 320000, 4480, 40),
  ('2026-08-01', 1, 'Retargeting',       50000, 120000, 1800, 15),
  ('2026-09-01', 2, 'Conversion',       140000, 640000, 5120, 58),
  ('2026-09-01', 3, 'Conversion',       100000, 335000, 4690, 42),
  ('2026-09-01', 4, 'Conversion',        45000, 150000, 2100, 20),
  -- Q4
  ('2026-10-01', 2, 'Conversion',       150000, 680000, 5440, 62),
  ('2026-10-01', 3, 'Conversion',       105000, 350000, 4900, 44),
  ('2026-10-01', 1, 'Retargeting',       55000, 130000, 1950, 16),
  ('2026-11-01', 2, 'Brand_Awareness',  160000, 720000, 5760, 66),
  ('2026-11-01', 3, 'Conversion',       110000, 365000, 5110, 46),
  ('2026-11-01', 4, 'Conversion',        50000, 160000, 2240, 22),
  ('2026-12-01', 2, 'Conversion',       170000, 760000, 6080, 70),
  ('2026-12-01', 3, 'Conversion',       115000, 380000, 5320, 48),
  ('2026-12-01', 1, 'Retargeting',       65000, 140000, 2100, 18);
