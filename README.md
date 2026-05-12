# D2C ROI & Business Intelligence Analytics

**Full-stack analytics project**

> A business intelligence case study combining an interactive financial simulator (Vercel), a relational SQL data model, and a Tableau dashboard — built to analyse D2C unit economics, pricing strategy, and profitability for a supplement brand.

[![Live Demo](https://img.shields.io/badge/Live%20Demo-Vercel-black?style=flat-square&logo=vercel)](https://interactive-12-month-revenue-projec.vercel.app/)
[![Tableau Dashboard](https://img.shields.io/badge/Tableau-Public%20Dashboard-blue?style=flat-square&logo=tableau)](https://public.tableau.com/views/D2C-Analytics/D2CAnalytics?:language=en-US&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)
[![SQL](https://img.shields.io/badge/SQL-PostgreSQL%2015-336791?style=flat-square&logo=postgresql)](./sql/)
---

## Business Case Summary

### Problem
A D2C supplement brand needed a structured way to evaluate pricing, marketing spend, and profitability across Amazon, quick-commerce, and D2C channels without relying on manual spreadsheets.

### Approach
Developed an integrated analytics solution combining a financial simulator, SQL data model, and Tableau dashboard to model CAC, retention, channel mix, and unit economics over a 12-month horizon.

### Metrics
COGS, gross margin, CAC, ROAS, retention rate, platform fees, net profit

### Outcome
Enabled stakeholders to simulate pricing and growth scenarios in real time, identify break-even ROAS thresholds, and make data-driven decisions on channel strategy and marketing investment.

---

## Project Overview

A D2C supplement brand entering the market holds a structural **COGS advantage of 25–30%** over competitors. This project quantifies that advantage and models a **12-month go-to-market strategy** across Amazon, Blinkit/Zepto, and D2C channels.

### Business Questions Addressed
- What is the break-even ROAS by channel given the brand’s COGS advantage?  
- How does CAC evolve over time with word-of-mouth effects?  
- Which channel mix maximises profitability under a fixed ad budget?  
- At what retention rate does the business become sustainably profitable?  
- How does gross margin compare with competing brands?  

---

## Tech Stack

| Layer | Tool | Purpose |
|---|---|---|
| Frontend Simulator | HTML / CSS / JS + Chart.js | Interactive, zero-dependency financial modeling |
| Data Model | PostgreSQL 15 | Structured analytics with star schema & SQL queries |
| BI Dashboard | Tableau Public | KPI tracking, visualization, and storytelling |
| Hosting | Vercel + GitHub | Deployment and version control |

---

## Dashboard & SQL Model

### SQL Data Model
Designed using a **star schema** with:
- `fact_orders` — order-level revenue and margin  
- `fact_ad_spend` — channel-level marketing spend  
- Dimension tables for product, channel, and customer  

### Key Analytical Logic
- CAC decay modelling (word-of-mouth impact)  
- Break-even ROAS calculation  
- Retention-based revenue forecasting  
- Blended platform fee modelling across channels  

---

## Dashboard Views (Tableau)

| View | Insight |
|------|--------|
| Monthly P&L | Tracks revenue vs profitability trends |
| Channel Mix | Identifies revenue vs margin contribution |
| Customer Growth | Analyzes retention vs acquisition |
| CAC vs ROAS | Measures marketing efficiency over time |
| Product Mix | Highlights top-performing SKUs |
| Persona Analysis | Identifies high-value customer segments |
| Break-even ROAS | Quantifies structural cost advantage |

---

## Key Business Insights

1. **COGS advantage drives profitability**  
   Lower production cost enables break-even at a significantly lower ROAS compared to competitors.

2. **Channel trade-offs matter**  
   Quick-commerce has higher fees but drives higher purchase frequency, impacting overall profitability.

3. **Retention is a growth lever**  
   Repeat customers overtake new users within months, making retention strategies critical.

4. **CAC improves over time**  
   Organic growth and word-of-mouth reduce acquisition cost significantly, improving long-term ROI.

---

## Context

This project was developed as part of professional work for a D2C supplement brand and is presented as a portfolio case study demonstrating:

- D2C unit economics and pricing strategy  
- SQL-based data modelling and analytics  
- BI dashboard design and KPI tracking  
- Decision-support tools for non-technical stakeholders  

---

## Disclaimer

Financial projections are illustrative and based on industry benchmarks. Data has been synthesised for portfolio purposes.
