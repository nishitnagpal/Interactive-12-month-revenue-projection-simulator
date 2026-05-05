# D2C ROI Analytics Suite

**Full-stack analytics project**

> A complete business intelligence portfolio project combining an interactive financial simulator (live at Vercel), a relational SQL data model, and a Tableau Public dashboard — built to demonstrate D2C unit economics analysis for a real supplement brand.

[![Live Demo](https://img.shields.io/badge/Live%20Demo-Vercel-black?style=flat-square&logo=vercel)](https://your-vercel-url.vercel.app)
[![Tableau Dashboard](https://img.shields.io/badge/Tableau-Public%20Dashboard-blue?style=flat-square&logo=tableau)](https://public.tableau.com/your-dashboard-link)
[![SQL](https://img.shields.io/badge/SQL-PostgreSQL%2015-336791?style=flat-square&logo=postgresql)](./sql/)

---

## Project Overview

A brand is entering the D2C supplement market as India's first. As the raw material distributor, the brand holds a structural COGS advantage of 25–30% over competitor brands — this project quantifies that edge and models a 12-month go-to-market strategy across Amazon, Blinkit/Zepto, and D2C channels.

**Business questions this project answers:**
- What is the break-even ROAS at each channel, given the brand's distributor COGS?
- How does CAC evolve over 12 months as word-of-mouth compounds?
- Which channel mix maximises net profit at a certain ₹X/month ad spend?
- At what retention rate does the business become sustainably profitable?
- How does the brand's gross margin compare to other incumbents?

---

## Repository Structure

```
root/
├── index.html                  # Interactive ROI Simulator (Vercel deploy)
├── sql/
│   ├── 01_schema.sql           # Relational schema (PostgreSQL)
│   ├── 02_seed_data.sql        # 12-month synthetic order + ad spend data
│   └── 03_analytical_queries.sql  # 7 analytical queries powering the dashboard
├── data/
│   ├── orders.csv              # 15,000+ order rows (Tableau data source)
│   ├── ad_spend.csv            # Monthly spend by channel & campaign type
│   └── monthly_summary.csv    # Aggregated KPIs — quick Tableau connect
├── docs/
│   └── tableau_setup.md        # Step-by-step Tableau Public setup guide
└── README.md
```

---

## Tech Stack

| Layer | Tool | Why |
|---|---|---|
| Frontend Simulator | HTML / CSS / JS + Chart.js | Zero-dependency, Vercel-deployable |
| Data Model | PostgreSQL 15 | Industry standard, GENERATED columns, window functions |
| BI Dashboard | Tableau Public | Free, shareable, most requested in German BI job descriptions |
| Hosting | Vercel (frontend) + GitHub | CI/CD on push, free tier |

---

## Getting Started

### Run the Simulator Locally

```bash
git clone https://github.com/nishitnagpal/Interactive-12-month-revenue-projection-simulator.git
cd Interactive-12-month-revenue-projection-simulator
# Open index.html directly in browser — no build step needed
open index.html
```
---

## SQL Model — Key Design Decisions

### Schema
The schema follows a **star schema** pattern with two fact tables and three dimension tables:

- `fact_orders` — one row per order, with `GENERATED` columns for revenue and gross margin
- `fact_ad_spend` — monthly spend by channel and campaign type
- `dim_channel` — platform fee rates (Amazon 35%, Blinkit/Zepto 38%, D2C 10%)
- `dim_product` — SKU-level pricing and COGS
- `dim_customer` — acquisition channel, persona, city tier

### Key Analytical Patterns Used
- **CAC decay model**: `CAC × 0.80^quarter` — models word-of-mouth compounding
- **Blended platform fee**: weighted average across channel mix
- **Break-even ROAS**: `1 / (gross_margin - platform_fee_rate)`
- **Retention modelling**: cumulative customer base × retention rate × time multiplier

---

## Dashboard Views (Tableau)

| Sheet | Chart Type | Business Question |
|---|---|---|
| Monthly P&L | Dual-bar (Revenue + Profit) | Is the business profitable month-on-month? |
| Channel Mix | Stacked bar + pie | Which channel drives most revenue vs most margin? |
| Customer Growth | Stacked bar (new vs repeat) | Is retention building over time? |
| CAC vs ROAS | Dual-axis line | Is acquisition efficiency improving? |
| Product Mix | Treemap | Which SKU drives the most revenue? |
| Persona Heatmap | Highlight table | Who is the most valuable customer segment? |
| Break-even ROAS | KPI table + reference line | What is TCC's structural cost advantage? |

---

## Key Business Insights

1. **Brand's COGS advantage is decisive**: At a 0.50× COGS multiplier vs 0.90× for competitors, the brand's break-even ROAS on Amazon is ~1.4× vs ~3.3× for incumbents, meaning campaigns are profitable at less than half the revenue threshold.

2. **Blinkit is the highest-fee but lowest-friction channel**: 38% platform fee, but impulse purchase behaviour drives higher order frequency for the trial SKU.

3. **Retention compounds fast**: At 35% monthly retention, repeat customers overtake new customers by month 7, making early retention investment (subscription, loyalty) high-ROI.

4. **CAC halves by Q4**: Word-of-mouth in the biohacker/gym and related persona based community reduces paid CAC by ~50% over 12 months, improving ROAS significantly in the back half of the year.

---

## Context

This project was built as part of professional work for the brand and is presented here as a portfolio demonstration of:
- **D2C unit economics modelling** (relevant to e-commerce/FMCG analyst roles)
- **SQL data modelling** (star schema, analytical queries, window functions)
- **BI dashboard design** (Tableau, KPI selection, business storytelling)
- **Stakeholder-facing tools** (the simulator was built to let non-technical founders stress-test assumptions)

---

## Disclaimer

Financial projections are illustrative and based on 2026 Indian D2C benchmarks. Data has been synthesised for portfolio purposes. Not financial advice.
