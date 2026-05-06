-- ============================================================
-- TCC Goat Whey · D2C Analytics Schema
-- Author : [Your Name]
-- Purpose: Simulate D2C/marketplace order + ad spend data
--          for BI analysis in Tableau / Looker Studio
-- Engine : PostgreSQL 15+ (also runs on SQLite with minor tweaks)
-- ============================================================


-- ────────────────────────────────────────────────────────────
-- 1. DIMENSIONS
-- ────────────────────────────────────────────────────────────

CREATE TABLE dim_channel (
    channel_id   SERIAL PRIMARY KEY,
    channel_name VARCHAR(40) NOT NULL,   -- 'D2C', 'Amazon', 'Blinkit', 'Zepto'
    platform_fee_rate NUMERIC(5,4) NOT NULL,  -- e.g. 0.3500 = 35%
    channel_type VARCHAR(20)            -- 'marketplace', 'quick_commerce', 'd2c'
);

CREATE TABLE dim_product (
    product_id      SERIAL PRIMARY KEY,
    sku             VARCHAR(30) NOT NULL UNIQUE,
    product_name    VARCHAR(100) NOT NULL,
    variant         VARCHAR(40),        -- '250g Trial', '500g Standard', '1kg Bulk'
    mrp             NUMERIC(10,2) NOT NULL,
    cogs_per_unit   NUMERIC(10,2) NOT NULL,
    gross_margin    NUMERIC(5,4) GENERATED ALWAYS AS
                        ((mrp - cogs_per_unit) / mrp) STORED
);

CREATE TABLE dim_customer (
    customer_id     SERIAL PRIMARY KEY,
    acquisition_month DATE NOT NULL,
    acquisition_channel_id INT REFERENCES dim_channel(channel_id),
    city_tier       VARCHAR(10),        -- 'Tier1', 'Tier2', 'Tier3'
    age_band        VARCHAR(10),        -- '18-24', '25-34', '35-44', '45+'
    persona         VARCHAR(30)         -- 'Biohacker', 'Athlete', 'Wellness', 'General'
);


-- ────────────────────────────────────────────────────────────
-- 2. FACTS
-- ────────────────────────────────────────────────────────────

CREATE TABLE fact_orders (
    order_id        SERIAL PRIMARY KEY,
    order_date      DATE NOT NULL,
    customer_id     INT  REFERENCES dim_customer(customer_id),
    channel_id      INT  REFERENCES dim_channel(channel_id),
    product_id      INT  REFERENCES dim_product(product_id),
    quantity        INT  NOT NULL DEFAULT 1,
    unit_price      NUMERIC(10,2) NOT NULL,   -- actual selling price (after discount)
    discount_amt    NUMERIC(10,2) DEFAULT 0,
    revenue         NUMERIC(10,2) GENERATED ALWAYS AS
                        (quantity * unit_price) STORED,
    cogs_total      NUMERIC(10,2),
    platform_fee    NUMERIC(10,2),
    is_repeat_order BOOLEAN DEFAULT FALSE
);

CREATE TABLE fact_ad_spend (
    spend_id        SERIAL PRIMARY KEY,
    spend_month     DATE NOT NULL,          -- first day of month
    channel_id      INT  REFERENCES dim_channel(channel_id),
    campaign_type   VARCHAR(30),            -- 'Brand_Awareness', 'Retargeting', 'Conversion'
    spend_amount    NUMERIC(12,2) NOT NULL,
    impressions     INT,
    clicks          INT,
    new_customers_acquired INT
);

-- ────────────────────────────────────────────────────────────
-- 3. INDEXES
-- ────────────────────────────────────────────────────────────

CREATE INDEX idx_orders_date     ON fact_orders(order_date);
CREATE INDEX idx_orders_customer ON fact_orders(customer_id);
CREATE INDEX idx_orders_channel  ON fact_orders(channel_id);
CREATE INDEX idx_spend_month     ON fact_ad_spend(spend_month);
