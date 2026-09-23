# 🛒 Retail Key Account Profitability & Cost-to-Serve Diagnostic

> Retail Key Account Profitability Diagnostic | $1.92M sales | Python · SQL · Power BI | $291K hidden losses uncovered | 48.98% loss-making transactions | Small-order cost-to-serve & KAM tier classification | SuperStore US H1 2015

---

## 📌 Project Snapshot

| Metric | Value |
|--------|-------|
| Total Sales Analyzed | $1.92M |
| Total Profit | $224K |
| Profit Margin % | 11.64% |
| Total Transactions | 1,952 |
| Unique Orders | 1,365 |
| Total Customers | 1,130 |
| Loss-Making Transactions | 956 (48.98%) |
| Total Loss Amount | -$291.45K |
| Regions Covered | 4 (Central, East, South, West) |
| Product Categories | 3 (Furniture, Office Supplies, Technology) |

---

## 📸 Dashboard Preview

> 📂 Uploaded screenshots to the `dashboard_screenshot` folder.

### Page 1 — Executive Summary
<!-- Upload: page1_executive_summary.png -->

### Page 2 — Customer Profitability
<!-- Upload: page2_customer_profitability.png -->

### Page 3 — Discount vs Profit (Leakage Detection)
<!-- Upload: page3_discount_vs_profit.png -->

### Page 4 — Product Analysis
<!-- Upload: page4_product_analysis.png -->

### Page 5 — Regional Profitability
<!-- Upload: page5_regional_profitability.png -->

### Page 6 — Strategic Account Scorecard
<!-- Upload: page6_strategic_account_scorecard.png -->

---

## 🧩 Business Problem

A retail business needed to understand:
- Which customers are destroying margin despite high revenue
- Whether discounting is actually the driver of loss, or whether something else is
- Which products and sub-categories are structurally loss-making
- Which regions are underperforming and why
- How to classify accounts into actionable KAM (Key Account Management) tiers

---

## 📂 Dataset Overview

| Attribute | Details |
|-----------|---------|
| Source | SuperStore US (public retail dataset) |
| Time Period | H1 2015 (January – June 2015) |
| Regions | Central, East, South, West |
| Product Categories | Furniture, Office Supplies, Technology |
| Customer Segments | Consumer, Corporate, Home Office, Small Business |
| Key Metrics | Sales, Profit, Discount %, Profit Margin %, Loss Transactions |

> ⚠️ Dataset is publicly available and used for portfolio/analytical purposes only.

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|------|---------|
| **Python** (Pandas, Matplotlib, Seaborn) | Data cleaning, EDA, profitability segmentation |
| **SQL** (PostgreSQL) | KPI aggregation, customer-level profitability, loss detection |
| **Power BI** | 6-page interactive dashboard, DAX measures, KAM tier classification |
| **Excel** | Source data (SuperStore US) |

---

## 🔄 Project Workflow

```
SuperStore US Excel Data
    │
    ▼
[SQL] → KPI queries, customer & regional profitability, high-risk account flagging
    │
    ▼
[Python] → Data cleaning, EDA, loss transaction analysis, margin distribution
    │
    ▼
[Power BI] → 6-page dashboard: Executive view → Customer → Discount → Product → Region → KAM Scorecard
```

---

## 🔍 Key Analysis Performed

**SQL**
- Customer-level profit margin and loss transaction identification
- High-discount / below-margin account flagging (customer_id grouping)
- Regional profitability ranking with loss transaction %
- Product category margin analysis
- Profit concentration (Pareto) analysis

**Python**
- Null handling, type casting, data validation
- Profit margin distribution and outlier detection
- Loss vs. profit transaction size comparison (cost-to-serve signal)
- Top 10 profitable vs. loss-making customer identification
- Customer-level aggregation and strategic tier classification

**Power BI (DAX)**
- Profit Margin % = Total Profit / Total Sales
- Loss Transaction % flag for accounts below zero profit
- Strategic Tier classification: Strategic Core / Standard / Margin Risk / Loss-Making
- Dynamic slicers: Year, Region, Product Category
- KAM Scorecard with per-customer tier assignment

---

## 📊 Dashboard Highlights

6-page interactive Power BI dashboard with year, region, and product slicers:

| Page | Focus |
|------|-------|
| **Executive Summary** | Top-line KPIs, sales & profit trend, profit margin by category, sales by segment |
| **Customer Profitability** | Top 10 profitable vs. loss-making customers, revenue vs. profit scatter |
| **Discount vs Profit** | High-discount/low-margin account detection, monthly discount-margin trend |
| **Product Analysis** | Loss-making products, sub-category treemap, category margin comparison |
| **Regional Profitability** | Region-wise margin, loss transaction %, revenue per customer |
| **Strategic Account Scorecard** | KAM tier classification, strategic core vs. loss-making account breakdown |

---

## 💡 Key Insights

- ⚠️ **48.98% of transactions are loss-making** — total loss of $291.45K hidden within $1.92M revenue
- 📦 **Not a discounting problem** — only 2 of 1,952 transactions carry a discount above 10%, and discount has virtually no correlation with profit (r ≈ -0.06). Loss-making transactions average **$590** in sales vs. **$1,366** for profitable ones — the real driver is small-order cost-to-serve
- 📍 **South region = net loss** (-4.04% margin) with the highest loss transaction rate (52.71%)
- 🏆 **Central = best region** at 17.26% margin; East and West both around 14%
- 🪑 **Furniture is structurally the lowest margin category** at ~9% — a base pricing/cost issue, not a discount issue
- 🖥️ **Technology margin (10.57%) sits below portfolio average** and is the deepest loss driver within high-discount/low-margin accounts (-49.38% margin in that group)
- 📉 **Office Machines is the most loss-making sub-category** (-$67,907); the single biggest loss-making product is the **Polycom ViewStation ISDN Videoconferencing Unit** (-$27,621)
- 🎯 **141 customers classified as Strategic Core** — protecting these accounts is critical
- 👤 **Corporate segment drives the largest share of revenue** (34.18%), ahead of Home Office (24.14%), Consumer (20.88%), and Small Business (20.80%)
- 🔴 **539 customers (47.7%) classified as Loss-Making** — immediate account review needed
- 📈 **156 of 591 profitable customers (26.4%) generate 80% of total profit** — a small group with outsized P&L impact

---

## ✅ Business Recommendations

1. **Minimum Order Value Threshold** — Introduce a floor on order size to reduce high-cost-to-serve small orders, which are the primary driver of loss transactions (not discounting)
2. **South Region** — Launch a profitability and cost-to-serve review; margin is negative and loss-transaction rate is highest of all regions
3. **Furniture Category** — Review base pricing/cost structure (not discounting) for Tables and other low-margin sub-categories; consider a minimum margin floor
4. **Technology Pricing Review** — Within the 370 flagged high-discount/low-margin accounts, Technology shows the deepest loss (-49.38%) and is the first place to review pricing/discount terms
5. **Strategic Core Accounts (141 customers)** — Assign dedicated KAM; prioritize retention, upsell, and margin protection
6. **Loss-Making Accounts (539 accounts, 47.7%)** — Segment into recoverable vs. unrecoverable; apply corrective pricing, minimum order value rules, or an exit strategy
7. **Top-Profit Customer Retention** — Build structured account reviews and churn early-warning indicators for the 156 customers who generate 80% of profit

---

## 📁 Repository Structure

```
retail-key-account-profitability-analysis/
│
├── data/
│   └── SuperStoreUS_data.xlsx                                    # Source dataset
│
├── notebooks/
│   └── retail_key_account_profitability_analysis.ipynb           # Python EDA & cleaning
│
├── sql/
│   └── retail_key_account_profitability_analysis.sql             # Analytical SQL queries
│
├── dashboard/
│   └── retail_key_account_profitability_dashboard.pbix           # Power BI file
│
├── dashboard_screenshot/
│   ├── page1_executive_summary.png
│   ├── page2_customer_profitability.png
│   ├── page3_discount_vs_profit.png
│   ├── page4_product_analysis.png
│   ├── page5_regional_profitability.png
│   └── page6_strategic_account_scorecard.png
│
└── README.md
```

---

## 🙋 About

**Prince Kumar** — Data Analyst | Python | SQL | Power BI | Excel | Tableau
---

*⭐ If you found this project useful, consider starring the repository!*
