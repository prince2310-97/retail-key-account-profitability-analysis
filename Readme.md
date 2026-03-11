# 🛒 Retail Key Account Profitability Diagnostic

> Retail Key Account Profitability Diagnostic | $1.92M sales | Python · SQL · Power BI | $291K hidden losses uncovered | 48.98% loss transactions | Discount governance failure & KAM tier classification | SuperStore US H1 2015

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
| Loss Transactions | 956 (48.98%) |
| Total Loss Amount | -$291.45K |
| Regions Covered | 4 (Central, East, South, West) |
| Product Categories | 3 (Furniture, Office Supplies, Technology) |

---

## 📸 Dashboard Preview

> 📂 Uploaded screenshots to the `dashboard-screenshots` folder.

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
- Where discount governance is failing and causing profit leakage
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
| **SQL** (PostgreSQL) | KPI aggregation, discount band analysis, loss detection |
| **Power BI** | 6-page interactive dashboard, DAX measures, KAM tier classification |
| **Excel** | Source data (SuperStore US) |

---

## 🔄 Project Workflow

```
SuperStore US Excel Data
    │
    ▼
[SQL] → KPI queries, discount band classification, customer & regional profitability
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
- Discount band segmentation (No / Low / Medium / High discount)
- Regional profitability ranking with loss transaction %
- Product sub-category margin analysis
- Revenue per customer by region

**Python**
- Null handling, type casting, data validation
- Profit margin distribution and outlier detection
- Discount vs. profit correlation analysis
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
| **Discount vs Profit** | Leakage detection, discount band analysis, monthly discount-margin trend |
| **Product Analysis** | Loss-making products, sub-category treemap, category margin comparison |
| **Regional Profitability** | Region-wise margin, loss transaction %, revenue per customer |
| **Strategic Account Scorecard** | KAM tier classification, strategic core vs. loss-making account breakdown |

---

## 💡 Key Insights

- ⚠️ **48.98% of orders are loss-making** — total loss of $291.45K hidden within $1.92M revenue
- 📍 **South region = net loss** (-4.04% margin) with highest loss transaction rate (52.71%)
- 🏆 **Central = best region** at 17.26% margin; East and West at ~14%
- 🪑 **Furniture is structurally the lowest margin category** at ~9%; dragged further by Tables sub-category
- 📄 **Paper sub-category = highest individual losses**; Xerox brand products are major loss drivers
- 💸 **High discount (21-30%) = guaranteed negative margin** — governance required immediately
- 📈 **Low discount (1-10%) = highest profit sweet spot** across all categories
- 🎯 **151 customers classified as Strategic Core** — protecting these accounts is critical
- 👤 **Consumer segment drives 34% of revenue** but high volume of loss transactions
- 🔴 **567 customers (47.6%) classified as Loss-Making** — immediate account review needed

---

## ✅ Business Recommendations

1. **South Region** — Launch immediate profitability audit; restrict high-discount approvals; review distributor and pricing strategy
2. **Discount Governance** — Cap discounts above 20% with mandatory approval workflow; enforce at order entry level
3. **Furniture Category** — Discontinue or reprice Tables sub-category; impose minimum margin floor of 10% per order
4. **Paper / Xerox Products** — Flag for product rationalization; remove or reprice loss-making SKUs
5. **Strategic Core Accounts (151 customers)** — Assign dedicated KAM; prioritize retention, upsell, and margin protection
6. **Loss-Making Accounts (567 accounts, 47.6%)** — Segment into recoverable vs. unrecoverable; apply corrective pricing or exit strategy
7. **Consumer Segment** — Introduce minimum order value thresholds to reduce low-value, high-discount loss orders

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
├── assets/
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

**Prince Kumar** — Data Analyst | Python · SQL · Power BI · Excel

[![LinkedIn](https://www.linkedin.com/feed/?trk=sem-ga_campid.14650114788_asid.151761418307_crid.657403558715_kw.linkedin%20profile_d.c_tid.kwd-10521864172_n.g_mt.e_geo.1007828)
[![GitHub](https://github.com/prince2310-97)
---

*⭐ If you found this project useful, consider starring the repository!*
