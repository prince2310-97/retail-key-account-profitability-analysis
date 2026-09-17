-- ============================================================================================================================
--  KEY ACCOUNT PROFITABILITY & DISCOUNT GOVERNANCE ANALYSIS
--  SQL Analytics Script — H1 2015 (January to June 2015)
--  Database  : superstore_analysis
--  Table     : orders
--  Author    : prince kumar
--  Purpose   : Customer profitability, discount leakage, concentration risk, category margin pressure
-- ============================================================================================================================
--
--  COLUMN REFERENCE (orders table):
--  order_date            DATE          — Date of order placement
--  customer_id           INT           — Unique customer identifier
--  customer_segment      VARCHAR(50)   — Corporate / Consumer / Home Office / Small Business
--  region                VARCHAR(20)   — West / East / Central / South
--  product_category      VARCHAR(50)   — Technology / Furniture / Office Supplies
--  sales                 DECIMAL(10,2) — Transaction revenue
--  profit                DECIMAL(10,4) — Transaction profit (can be negative)
--  discount              DECIMAL(5,4)  — Discount applied (0.0 to 1.0 scale)
--  quantity              INT           — Units ordered
--  unit_price            DECIMAL(10,2) — Price per unit
--  shipping_cost         DECIMAL(10,2) — Shipping cost per transaction
--  order_priority        VARCHAR(20)   — High / Medium / Low / Not Specified
--  product_base_margin   DECIMAL(5,4)  — Base margin of product
--
-- ============================================================================================================================
-- ============================================================================================================================
-- SECTION 1 : PORTFOLIO-LEVEL KPI BASELINE
-- ============================================================================================================================

/*
  OBJECTIVE    : Establish the H1 2015 commercial baseline before any customer-level drill-down.
  WHY IT MATTERS : Before identifying problems, leadership needs a single-view snapshot of
                   the portfolio. Revenue looks healthy at ~$1.92M, but this query forces
                   the question — at what margin?
  INSIGHT      : Average discount is ~4.9% versus portfolio margin of ~11.64%. Discount alone
                 is not the primary driver of portfolio losses; customer-level profitability
                 and small-order cost-to-serve are the key focus areas (see Section 4/5/8).
*/

SELECT

    COUNT(*)                                                                AS Total_Transactions,
    COUNT(DISTINCT customer_id)                                             AS Unique_Customers,
    ROUND(SUM(sales), 0)                                                    AS Total_Revenue,
    ROUND(SUM(profit), 0)                                                   AS Total_Profit,
    ROUND(SUM(profit) * 100.0 / NULLIF(SUM(sales), 0), 2)                  AS Portfolio_Margin_Pct,
    ROUND(AVG(discount) * 100, 2)                                           AS Avg_Discount_Pct,
    ROUND(AVG(profit * 100.0 / NULLIF(sales, 0)), 2)                       AS Avg_Transaction_Margin_Pct,
    ROUND(SUM(sales) / NULLIF(COUNT(DISTINCT customer_id), 0), 2)          AS Revenue_Per_Customer

FROM orders
WHERE order_date BETWEEN '2015-01-01' AND '2015-06-30';

/*
  EXPECTED OUTPUT  : 1 row. Avg_Discount_Pct ~4.9%, Portfolio_Margin_Pct ~11.64%.
                     48.98% of transactions are loss-making despite modest average discounting.
  BUSINESS REACTION: Since discounting is low and broad-based, the leakage is not explained
                     by discount policy alone. Leadership should look at customer-level
                     profitability and small-order cost-to-serve (Sections 4/5/8) as the
                     primary lever, not a blanket discount cap.
*/




-- ============================================================================================================================
-- SECTION 2 : CUSTOMER-LEVEL PROFITABILITY RANKING
-- ============================================================================================================================

/*
  OBJECTIVE    : Build a full customer profitability view and rank accounts by total profit
                 contribution using window functions.
  WHY IT MATTERS : This is the foundation of Key Account Management. Revenue rank alone is
                   misleading — a customer generating $50K in sales at -10% margin costs
                   more to serve than a $20K customer at 25% margin.
  INSIGHT      : Window ranking by profit separates true value creators from revenue inflators.
                 Any customer in top-10 by revenue but bottom-half by profit is a red flag.
*/

SELECT
    customer_id,
    MAX(customer_segment) AS customer_segment,
    MAX(region) AS region,
    ROUND(SUM(sales), 2) AS Total_Sales,
    ROUND(SUM(profit), 2) AS Total_Profit,
    COUNT(*) AS Total_Orders,
    SUM(quantity) AS Total_Units,
    ROUND(AVG(discount) * 100, 2) AS Avg_Discount_Pct,
    ROUND(SUM(profit) * 100.0 / NULLIF(SUM(sales), 0), 2) AS Overall_Margin_Pct,

    DENSE_RANK() OVER (
        ORDER BY SUM(sales) DESC
    ) AS Revenue_Rank,

    DENSE_RANK() OVER (
        ORDER BY SUM(profit) DESC
    ) AS Profit_Rank

FROM orders
WHERE order_date BETWEEN '2015-01-01' AND '2015-06-30'
GROUP BY customer_id
ORDER BY Total_Profit DESC;

/*
  EXPECTED OUTPUT  : 1 row per customer. Compare Revenue_Rank vs Profit_Rank.
                     Large divergence = account generating revenue at cost of margin.
  BUSINESS REACTION: Any top-50 revenue account with negative Overall_Margin_Pct needs
                     immediate commercial review.
*/




-- ============================================================================================================================
-- SECTION 3 : STRATEGIC ACCOUNT TIER CLASSIFICATION
-- ============================================================================================================================

/*
  OBJECTIVE    : Classify all customers into strategic tiers based on revenue quartile
                 and profitability, enabling structured prioritization of commercial effort.
  WHY IT MATTERS : Not all customers deserve the same level of attention. A tiered model
                   ensures KAM resources go to accounts that generate sustainable profit,
                   not just revenue volume.
  INSIGHT      : Four tiers — Strategic Core, Margin Risk, Loss-Making, Standard.
                 Each tier has a different commercial response.
*/

WITH Customer_Base AS (
    SELECT
       customer_id,
		MAX(customer_segment) AS customer_segment,
		MAX(region) AS region,
        ROUND(SUM(sales), 2)                                                AS Total_Sales,
        ROUND(SUM(profit), 2)                                               AS Total_Profit,
        COUNT(*)                                                            AS Total_Orders,
        SUM(quantity)                                                       AS Total_Units,
        ROUND(AVG(discount) * 100, 2)                                       AS Avg_Discount_Pct,
        ROUND(SUM(profit) * 100.0 / NULLIF(SUM(sales), 0), 2)              AS Overall_Margin_Pct
    FROM orders
    WHERE order_date BETWEEN '2015-01-01' AND '2015-06-30'
    GROUP BY customer_id
),

Revenue_Quartiles AS (
    SELECT *,
        NTILE(4) OVER (ORDER BY Total_Sales ASC)                            AS Revenue_Quartile
    FROM Customer_Base
)

SELECT
    customer_id,
    customer_segment,
    region,
    Total_Sales,
    Total_Profit,
    Total_Orders,
    Total_Units,
    Avg_Discount_Pct,
    Overall_Margin_Pct,
    Revenue_Quartile,

    CASE
        WHEN Revenue_Quartile = 4 AND Overall_Margin_Pct > 15
            THEN 'Strategic Core Account'
        WHEN Revenue_Quartile = 4 AND Overall_Margin_Pct <= 15
            THEN 'High Revenue - Margin Risk'
        WHEN Overall_Margin_Pct < 0
            THEN 'Loss-Making Account'
        ELSE
            'Standard Account'
    END                                                                     AS Strategic_Tier

FROM Revenue_Quartiles
ORDER BY Total_Sales DESC;

/*
  EXPECTED OUTPUT  : 1 row per customer with tier assigned.
  BUSINESS REACTION:
    STRATEGIC CORE     → Formal KAM coverage. Quarterly reviews. No extra discount without VP approval.
    MARGIN RISK        → Immediate pricing audit. Discount ceiling required. Monthly monitoring.
    LOSS-MAKING        → Contract review. Path to positive margin within 2 quarters or restructure.
    STANDARD           → Volume-managed. No special concessions without regional approval.
*/




-- ============================================================================================================================
-- SECTION 4 : DISCOUNT LEAKAGE DETECTION
-- ============================================================================================================================

/*
  OBJECTIVE    : Identify customers receiving above-average discounts while generating
                 below-average profitability — the clearest signal of discount leakage.
  WHY IT MATTERS : WHY IT MATTERS : Discount leakage can silently erode margins. These accounts highlight
                 where higher discounting is associated with below-average profitability.
  INSIGHT      : Portfolio avg discount and avg margin used as dynamic thresholds.
                 Any account above threshold discount AND below threshold margin is flagged.
*/

WITH Customer_Summary AS (
    SELECT
        customer_id,
		MAX(customer_segment) AS customer_segment,
		MAX(region) AS region,
        ROUND(SUM(sales), 2)                                                AS Total_Sales,
        ROUND(SUM(profit), 2)                                               AS Total_Profit,
        COUNT(*)                                                            AS Total_Orders,
        ROUND(AVG(discount) * 100, 2)                                       AS Avg_Discount_Pct,
        ROUND(SUM(profit) * 100.0 / NULLIF(SUM(sales), 0), 2)              AS Overall_Margin_Pct
    FROM orders
    WHERE order_date BETWEEN '2015-01-01' AND '2015-06-30'
    GROUP BY customer_id
),

Portfolio_Thresholds AS (
    -- Weighted portfolio-level thresholds (matches the headline KPIs in Section 1
    -- and the Python analysis), NOT an average of per-customer ratios — averaging
    -- per-customer % here lets a few tiny-sale customers with extreme margin%
    -- distort the threshold.
    SELECT
        (SELECT AVG(discount) * 100 FROM orders
         WHERE order_date BETWEEN '2015-01-01' AND '2015-06-30')            AS Avg_Portfolio_Discount,
        (SELECT SUM(profit) * 100.0 / SUM(sales) FROM orders
         WHERE order_date BETWEEN '2015-01-01' AND '2015-06-30')            AS Avg_Portfolio_Margin
)

SELECT
    cs.customer_id,
    cs.customer_segment,
    cs.region,
    cs.Total_Sales,
    cs.Total_Profit,
    cs.Avg_Discount_Pct,
    cs.Overall_Margin_Pct,
    ROUND(pt.Avg_Portfolio_Discount, 2)                                     AS Portfolio_Avg_Discount,
    ROUND(pt.Avg_Portfolio_Margin, 2)                                       AS Portfolio_Avg_Margin,

    CASE
        WHEN cs.Avg_Discount_Pct > (pt.Avg_Portfolio_Discount + 5)
            THEN 'HIGH LEAKAGE RISK'
        WHEN cs.Avg_Discount_Pct > pt.Avg_Portfolio_Discount
            THEN 'MODERATE LEAKAGE RISK'
        ELSE 'ACCEPTABLE'
    END                                                                     AS Leakage_Risk_Flag

FROM Customer_Summary cs
CROSS JOIN Portfolio_Thresholds pt
WHERE cs.Avg_Discount_Pct > pt.Avg_Portfolio_Discount
  AND cs.Overall_Margin_Pct < pt.Avg_Portfolio_Margin
ORDER BY cs.Avg_Discount_Pct DESC;

/*
  EXPECTED OUTPUT  : ~370 flagged accounts.
  BUSINESS REACTION: HIGH LEAKAGE RISK → Immediate pricing review within 30 days.
                     MODERATE LEAKAGE RISK → Watchlist. Cap further discounting.
*/




-- ============================================================================================================================
-- SECTION 5 : REVENUE IMPACT OF HIGH-RISK ACCOUNTS
-- ============================================================================================================================

/*
  OBJECTIVE    : Quantify how much of total H1 revenue comes from high-discount, low-margin
                 customers — to assess whether leakage is material or contained.
  WHY IT MATTERS : Leadership needs to know the revenue exposure in dollar terms.
  INSIGHT      : 5-6% leakage = manageable with governance. >15% = immediate escalation.
*/

WITH Customer_Summary AS (
    SELECT
        customer_id,
        ROUND(SUM(sales), 2)                                                AS Total_Sales,
        ROUND(AVG(discount) * 100, 2)                                       AS Avg_Discount_Pct,
        ROUND(SUM(profit) * 100.0 / NULLIF(SUM(sales), 0), 2)              AS Overall_Margin_Pct
    FROM orders
    WHERE order_date BETWEEN '2015-01-01' AND '2015-06-30'
    GROUP BY customer_id
),

Portfolio_Thresholds AS (
    -- Weighted portfolio-level thresholds (same definition as Section 4 and the
    -- headline KPIs in Section 1) — not an average of per-customer ratios.
    SELECT
        (SELECT AVG(discount) * 100 FROM orders
         WHERE order_date BETWEEN '2015-01-01' AND '2015-06-30')            AS Avg_Portfolio_Discount,
        (SELECT SUM(profit) * 100.0 / SUM(sales) FROM orders
         WHERE order_date BETWEEN '2015-01-01' AND '2015-06-30')            AS Avg_Portfolio_Margin
),

Flagged_Customers AS (
    SELECT cs.customer_id, cs.Total_Sales
    FROM Customer_Summary cs
    CROSS JOIN Portfolio_Thresholds pt
    WHERE cs.Avg_Discount_Pct > pt.Avg_Portfolio_Discount
      AND cs.Overall_Margin_Pct < pt.Avg_Portfolio_Margin
)

SELECT
    ROUND((SELECT SUM(Total_Sales) FROM Customer_Summary), 0)               AS Total_Portfolio_Revenue,
    ROUND(SUM(f.Total_Sales), 0)                                            AS High_Risk_Revenue,
    COUNT(f.customer_id)                                                    AS High_Risk_Account_Count,
    ROUND(
        SUM(f.Total_Sales) * 100.0 /
        NULLIF((SELECT SUM(Total_Sales) FROM Customer_Summary), 0), 2
    )                                                                       AS High_Risk_Revenue_Pct

FROM Flagged_Customers f;

/*
  EXPECTED OUTPUT  : 1 row. High_Risk_Revenue_Pct expected ~26.1% (370 accounts).
  BUSINESS REACTION: Results show ~26.1% of revenue sits with high-discount,
                     below-margin accounts — governance review needed, though this
                     is revenue exposure, not confirmed loss.
                     Leakage concentrated in Technology (-49.38% margin in risk accounts).
                     South region: -4.04% margin, 52.71% loss transactions — highest priority.
*/




-- ============================================================================================================================
-- SECTION 6 : PROFIT CONCENTRATION ANALYSIS (PARETO)
-- ============================================================================================================================

/*
  OBJECTIVE    : Determine what % of customers generate 80% of total profit.
  WHY IT MATTERS : If 80% of profit comes from 25% of customers, losing even 2-3 of those
                   accounts creates a P&L crisis. Retention strategy must protect this group.
  INSIGHT      : Expected: top ~26.4% of profitable customers (156 of 591) = ~80% of profit.
*/

WITH Customer_Profit AS (
    SELECT
        customer_id,
        ROUND(SUM(profit), 2)                                               AS Total_Profit
    FROM orders
    WHERE order_date BETWEEN '2015-01-01' AND '2015-06-30'
    GROUP BY customer_id
),

Profit_Ranked AS (
    SELECT
        customer_id,
        Total_Profit,
        ROW_NUMBER() OVER (ORDER BY Total_Profit DESC)                      AS Profit_Rank,
        COUNT(*) OVER ()                                                    AS Total_Customers,
        SUM(Total_Profit) OVER ()                                           AS Grand_Total_Profit,
        SUM(Total_Profit) OVER (
            ORDER BY Total_Profit DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )                                                                   AS Cumulative_Profit
    FROM Customer_Profit
    WHERE Total_Profit > 0
)

SELECT
    customer_id,
    Total_Profit,
    Profit_Rank,
    Total_Customers,
    ROUND(Profit_Rank * 100.0 / Total_Customers, 1)                        AS Customer_Pct,
    ROUND(Cumulative_Profit * 100.0 / NULLIF(Grand_Total_Profit, 0), 1)    AS Cumulative_Profit_Pct

FROM Profit_Ranked
ORDER BY Profit_Rank;

/*
  EXPECTED OUTPUT  : Profitable customers only. Cumulative_Profit_Pct hits 80% at
                     Customer_Pct = 26.4% (156 of 591 profitable customers).
  BUSINESS REACTION: Top quartile customers must have named account owner and quarterly
                     structured reviews. Build early warning churn indicators.
*/




-- ============================================================================================================================
-- SECTION 7 : CATEGORY-LEVEL MARGIN ANALYSIS
-- ============================================================================================================================

/*
  OBJECTIVE    : Compare margin structure across Technology, Furniture, and Office Supplies.
  WHY IT MATTERS : Separates structural margin issues from targeted pricing issues. Low
                   Furniture margin even at zero discount = cost/pricing issue. Technology
                   margin below the portfolio average warrants targeted pricing/discount
                   review. Response is fundamentally different per category.
  INSIGHT      : Office Supplies expected ~16% margin. Furniture structurally lower ~9%.
*/

SELECT
    product_category,
    COUNT(*)                                                                AS Total_Transactions,
    SUM(quantity)                                                           AS Total_Units_Sold,
    ROUND(SUM(sales), 0)                                                    AS Total_Revenue,
    ROUND(SUM(profit), 0)                                                   AS Total_Profit,
    ROUND(SUM(profit) * 100.0 / NULLIF(SUM(sales), 0), 2)                  AS Category_Margin_Pct,
    ROUND(AVG(discount) * 100, 2)                                           AS Avg_Discount_Pct,
    ROUND(AVG(unit_price), 2)                                               AS Avg_Unit_Price,
    ROUND(
        SUM(sales) * 100.0 /
        NULLIF((SELECT SUM(sales) FROM orders
                WHERE order_date BETWEEN '2015-01-01' AND '2015-06-30'), 0), 1
    )                                                                       AS Revenue_Share_Pct

FROM orders
WHERE order_date BETWEEN '2015-01-01' AND '2015-06-30'
GROUP BY product_category
ORDER BY Category_Margin_Pct DESC;

/*
  EXPECTED OUTPUT  : 3 rows. Office Supplies highest margin. Furniture lowest.
  BUSINESS REACTION: Furniture → Tighten pricing floor. Discount > 10% needs manager approval.
                     Technology → No discount > 20% without VP sign-off.
                     Office Supplies → Protect margin. Avoid commoditization pressure.
*/




-- ============================================================================================================================
-- SECTION 8 : HIGH-RISK ACCOUNT CATEGORY EXPOSURE
-- ============================================================================================================================

/*
  OBJECTIVE    : Within flagged high-risk accounts, identify which product categories are
                 generating the deepest losses.
  WHY IT MATTERS : If Technology drives most of the loss in high-risk accounts, the fix is a
                   Technology-specific pricing/discount review. If all categories are negative,
                   the issue is broader than one category or one discount band.
  INSIGHT      : NOTE — this group was defined as "below-average margin," so all three
                 categories showing negative margin here is expected by construction,
                 not new evidence. The useful read is the RELATIVE gap between categories
                 (which one is worst), not the fact that all are negative.
*/

WITH Customer_Summary AS (
    SELECT
        customer_id,
        ROUND(AVG(discount) * 100, 2)                                       AS Avg_Discount_Pct,
        ROUND(SUM(profit) * 100.0 / NULLIF(SUM(sales), 0), 2)              AS Overall_Margin_Pct
    FROM orders
    WHERE order_date BETWEEN '2015-01-01' AND '2015-06-30'
    GROUP BY customer_id
),

Portfolio_Thresholds AS (
    -- Weighted portfolio-level thresholds (same definition as Section 4/5).
    SELECT
        (SELECT AVG(discount) * 100 FROM orders
         WHERE order_date BETWEEN '2015-01-01' AND '2015-06-30')            AS Avg_Portfolio_Discount,
        (SELECT SUM(profit) * 100.0 / SUM(sales) FROM orders
         WHERE order_date BETWEEN '2015-01-01' AND '2015-06-30')            AS Avg_Portfolio_Margin
),

High_Risk_IDs AS (
    SELECT cs.customer_id
    FROM Customer_Summary cs
    CROSS JOIN Portfolio_Thresholds pt
    WHERE cs.Avg_Discount_Pct > pt.Avg_Portfolio_Discount
      AND cs.Overall_Margin_Pct < pt.Avg_Portfolio_Margin
)

SELECT
    o.product_category,
    COUNT(*)                                                                AS Transactions,
    SUM(o.quantity)                                                         AS Total_Units,
    ROUND(SUM(o.sales), 0)                                                  AS Total_Revenue,
    ROUND(SUM(o.profit), 0)                                                 AS Total_Profit,
    ROUND(SUM(o.profit) * 100.0 / NULLIF(SUM(o.sales), 0), 2)              AS Category_Margin_Pct,
    ROUND(AVG(o.discount) * 100, 2)                                         AS Avg_Discount_Pct

FROM orders o
WHERE o.customer_id IN (SELECT customer_id FROM High_Risk_IDs)
  AND o.order_date BETWEEN '2015-01-01' AND '2015-06-30'
GROUP BY o.product_category
ORDER BY Category_Margin_Pct ASC;

/*
  EXPECTED OUTPUT  : 3 rows. Technology ~-49% (deepest), Furniture ~-21%, Office Supplies ~-20%.
  BUSINESS REACTION: Technology deepest → review Technology-specific discount/pricing terms first.
                     Renegotiate commercial terms for these accounts as a group.
*/




-- ============================================================================================================================
-- SECTION 9 : REGIONAL PROFITABILITY BREAKDOWN
-- ============================================================================================================================

/*
  OBJECTIVE    : Compare commercial health across West, East, Central and South regions.
  WHY IT MATTERS : High revenue with poor margin is not a success — it is a commercial risk.
                   Regional incentives must align to margin, not just revenue.
  INSIGHT      : Loss_Transaction_Pct reveals profitability health per region.
                 High % indicates profitability and cost-to-serve pressure in that region.
*/

SELECT
    region,
    COUNT(DISTINCT customer_id)                                             AS Unique_Customers,
    COUNT(*)                                                                AS Total_Transactions,
    SUM(quantity)                                                           AS Total_Units_Sold,
    ROUND(SUM(sales), 0)                                                    AS Total_Revenue,
    ROUND(SUM(profit), 0)                                                   AS Total_Profit,
    ROUND(SUM(profit) * 100.0 / NULLIF(SUM(sales), 0), 2)                  AS Region_Margin_Pct,
    ROUND(AVG(discount) * 100, 2)                                           AS Avg_Discount_Pct,
    ROUND(SUM(sales) / NULLIF(COUNT(DISTINCT customer_id), 0), 2)          AS Revenue_Per_Customer,
    ROUND(SUM(profit) / NULLIF(COUNT(DISTINCT customer_id), 0), 2)         AS Profit_Per_Customer,
    SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END)                            AS Loss_Transactions,
    ROUND(
        SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END) * 100.0 /
        NULLIF(COUNT(*), 0), 1
    )                                                                       AS Loss_Transaction_Pct

FROM orders
WHERE order_date BETWEEN '2015-01-01' AND '2015-06-30'
GROUP BY region
ORDER BY Region_Margin_Pct DESC;

/*
  EXPECTED OUTPUT  : 4 rows. Regions vary on Loss_Transaction_Pct.
  BUSINESS REACTION: Region with Loss_Transaction_Pct > 30% needs immediate discount
                     policy review. Manager must approve discounts above portfolio average.
*/




-- ============================================================================================================================
-- SECTION 10 : SEGMENT-LEVEL COMMERCIAL SCORECARD
-- ============================================================================================================================

/*
  OBJECTIVE    : Rank each customer within their customer segment by total profit
                 and classify accounts into commercial action categories.

  WHY IT MATTERS : Segment-level benchmarks provide a fairer comparison of customers.
                   Ranking customers within their own segment reduces cross-segment
                   distortion and supports targeted commercial action.

  INSIGHT      : Customers are ranked by profit within their segment and classified
                 into four commercial action categories based on profitability
                 and segment-level performance.
*/

WITH Customer_Agg AS (
    SELECT
        customer_id,
        MAX(customer_segment) AS customer_segment,
        MAX(region) AS region,
        ROUND(SUM(sales), 2) AS Total_Sales,
        ROUND(SUM(profit), 2) AS Total_Profit,
        COUNT(*) AS Total_Orders,
        SUM(quantity) AS Total_Units,
        ROUND(AVG(discount) * 100, 2) AS Avg_Discount_Pct,
        ROUND(SUM(profit) * 100.0 / NULLIF(SUM(sales), 0), 2) AS Overall_Margin_Pct
    FROM orders
    WHERE order_date BETWEEN '2015-01-01' AND '2015-06-30'
    GROUP BY customer_id
),

Segment_Ranked AS (
    SELECT *,
        DENSE_RANK() OVER (
            PARTITION BY customer_segment
            ORDER BY Total_Profit DESC
        ) AS Segment_Profit_Rank,

        COUNT(*) OVER (
            PARTITION BY customer_segment
        ) AS Segment_Customer_Count

    FROM Customer_Agg
)

SELECT
    customer_id,
    customer_segment,
    region,
    Total_Sales,
    Total_Profit,
    Total_Orders,
    Total_Units,
    Avg_Discount_Pct,
    Overall_Margin_Pct,
    Segment_Profit_Rank,
    Segment_Customer_Count,

    ROUND(
        Segment_Profit_Rank * 100.0 /
        NULLIF(Segment_Customer_Count, 0),
        0
    ) AS Segment_Profit_Percentile,

    CASE
        WHEN Overall_Margin_Pct > 15
         AND Segment_Profit_Rank <= (Segment_Customer_Count * 0.25)
            THEN 'PROTECT - Core KAM Account'

        WHEN Overall_Margin_Pct > 0
         AND Segment_Profit_Rank <= (Segment_Customer_Count * 0.50)
            THEN 'MONITOR - Standard Coverage'

        WHEN Overall_Margin_Pct BETWEEN -5 AND 0
            THEN 'REVIEW - Discount Audit Required'

        WHEN Overall_Margin_Pct < -5
            THEN 'EXIT RISK - Immediate Commercial Action'

        ELSE
            'STANDARD - Routine Management'
    END AS Commercial_Action

FROM Segment_Ranked
ORDER BY customer_segment, Segment_Profit_Rank;

/*
  EXPECTED OUTPUT  : 1 row per unique customer with segment-level profit rank
                     and commercial action classification.

  BUSINESS REACTION:
    PROTECT        → Named KAM. Quarterly executive review. Proactive retention offer.
    MONITOR        → Standard sales rep coverage. Monthly check-in.
    REVIEW         → Discount audit within 30 days. Regional manager reviews next order.
    EXIT RISK      → Senior commercial review. Turnaround plan or account rationalization.
*/

-- ============================================================================================================================
-- ============================================================================================================================
--
--  EXECUTIVE SUMMARY — STRATEGIC FINDINGS FROM H1 2015 ANALYSIS
--  (For CCO / VP Sales / Finance Leadership Presentation)
--
-- ============================================================================================================================
-- ============================================================================================================================

/*
╔══════════════════════════════════════════════════════════════════════════════════════════════╗
║                    TOP 3 COMMERCIAL RISKS IDENTIFIED                                       ║
╚══════════════════════════════════════════════════════════════════════════════════════════════╝

  RISK 1 — SMALL-ORDER COST-TO-SERVE & CUSTOMER PROFITABILITY (HIGH SEVERITY)
  ────────────────────────────────────────────────────────────────────
  48.98% of transactions are loss-making, with loss-making transactions averaging ~$590
  in sales versus ~$1,366 for profitable transactions. Average discount (~4.9%) is close
  to profitable-transaction discount levels too, so discount alone is not the primary
  driver — small-order economics and cost-to-serve are the key focus areas.
  Action Required: Introduce a minimum order value threshold to reduce high-cost-to-serve
  small orders. Link FY2016 incentives to margin contribution, not revenue volume.

  RISK 2 — PROFIT CONCENTRATION IN TOP CUSTOMER QUARTILE (MEDIUM-HIGH SEVERITY)
  ──────────────────────────────────────────────────────────────────────────────
  Section 6 Pareto analysis confirms ~26.4% of profitable customers (156 of 591) generate
  ~80% of total profit. A churn event among top-quartile accounts is a P&L event, not just
  a relationship issue.
  Action Required: Identify top ~26% profit-contributing customers. Assign a named account
  manager to each. Initiate structured quarterly business reviews. Build early warning
  churn indicators: purchase frequency drop, discount request increase, category mix shift.

  RISK 3 — TECHNOLOGY CATEGORY DEEPLY NEGATIVE IN HIGH-RISK ACCOUNTS (MEDIUM SEVERITY)
  ──────────────────────────────────────────────────────────────────────────────────────
  Section 8 shows high-risk customers generate negative margins across all categories,
  with Technology showing the deepest loss. A single deeply discounted Technology order
  can wipe out profit from multiple standard Office Supplies transactions.
  Action Required: Review Technology pricing and margin terms for flagged high-risk accounts
  first, since it shows the deepest loss among the three categories in this group.


╔══════════════════════════════════════════════════════════════════════════════════════════════╗
║                    TOP 3 COMMERCIAL OPPORTUNITIES IDENTIFIED                               ║
╚══════════════════════════════════════════════════════════════════════════════════════════════╝

  OPPORTUNITY 1 — OFFICE SUPPLIES MARGIN EXPANSION (HIGH POTENTIAL)
  ──────────────────────────────────────────────────────────────────
  Section 7 confirms Office Supplies delivers the strongest structural margin (~16%).
  Yet even this category receives unnecessary discounts.
  Opportunity: Remove automatic discounting from Office Supplies for Standard Accounts.
  Apply discounts only when a competitive quote is presented, to protect this category's
  above-average margin.

  OPPORTUNITY 2 — SEGMENT-BASED PRICING FOR CORPORATE ACCOUNTS (HIGH POTENTIAL)
  ────────────────────────────────────────────────────────────────────────────────
  Section 10 scorecard shows Corporate segment contains both PROTECT and EXIT RISK accounts
  in the same revenue band. Corporate accounts are getting Consumer-level discounts without
  the volume to justify it.
  Opportunity: Introduce Corporate Volume Pricing Agreement — tiered pricing linked to
  actual purchase volume, not negotiation skill of the account.

  OPPORTUNITY 3 — FURNITURE MARGIN RECOVERY THROUGH PRICING FLOOR (MEDIUM POTENTIAL)
  ────────────────────────────────────────────────────────────────────────────────────
  Furniture operates at ~9% structural margin (Section 7) — the lowest of the three
  categories, largely a base-cost/pricing issue rather than a discounting issue.
  Opportunity: Implement a Furniture pricing floor and review cost/pricing on the
  worst-margin sub-categories (e.g. Tables). Review top-10 Furniture loss transactions
  from high-risk accounts for context.


╔══════════════════════════════════════════════════════════════════════════════════════════════╗
║                    HOW LEADERSHIP SHOULD USE THIS ANALYSIS                                  ║
╚══════════════════════════════════════════════════════════════════════════════════════════════╝

  FOR CCO / VP SALES:
  ───────────────────
  → Use Section 1 (Portfolio Baseline) and Section 9 (Regional Breakdown) for H1 board
    reporting. Define H2 margin targets at regional level.
  → Use Section 10 (Commercial Scorecard) to restructure FY2016 sales incentive plan.
    Any incentive not linked to margin is an incentive to discount.

  FOR REGIONAL SALES MANAGERS:
  ─────────────────────────────
  → Use Section 2 (Customer Ranking) and Section 4 (Leakage Detection) for monthly
    account reviews. Focus intervention on REVIEW and EXIT RISK accounts.
  → Use Section 8 (Category Exposure) to coach reps on where the biggest loss events are.

  FOR FINANCE / COMMERCIAL EXCELLENCE:
  ──────────────────────────────────────
  → Use Section 5 (Revenue Impact) to quantify leakage in dollar terms for CFO reporting.
    Track High_Risk_Revenue_Pct quarterly as a governance KPI.
  → Use Section 3 (Tier Classification) to build account master list that drives pricing
    policy, discount approval thresholds, and credit terms differentiation.

  FINAL NOTE:
  ───────────
  This framework should run at the end of every quarter.
  Sections 1, 4, and 5 should run monthly as an early warning system.
  Data without a review cadence is just a report.
  Data with a monthly management rhythm becomes a commercial control system.

*/

-- ============================================================================================================================
-- END OF SCRIPT — superstore_key_account_profitability_sql.sql
-- H1 2015 | superstore_analysis.orders
-- ============================================================================================================================
