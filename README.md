# Predictive Logistics Pipeline & Supply Chain Analytics
### End-to-End Data Engineering & Business Intelligence Project

**Business Objective:** Fragmented data across three relational datasets made it impossible for executive leadership to visualize the correlation between operational efficiency and revenue. This project consolidates 56,000+ shipment records and 750+ customer accounts to identify bottlenecks in an $11.36M revenue stream.

## 🛠️ Technology Stack
* **Database:** PostgreSQL (Cloud-hosted/Local)
* **ETL & Engineering:** SQL (JOINS, CTEs, Data Type Casting)
* **Visualization:** Tableau (Interactive Executive Dashboards)
* **Web Hosting:** GitHub Pages (Portfolio Site)

## 📈 Business Insights Discovered
* **The 91% Threshold:** Identified a critical operational "breaking point" where warehouse utilization over 91% causes nonlinear spikes in delivery delays (avg. +2.5 hours).
* **Profitability Leak:** Flagged 15% of shipments where freight costs exceeded 20% of order value, primarily in the South American corridor.
* **Customer Health:** Discovered a 0.42% damage claim rate, significantly below the industry average of 1.5%.

## 🗄️ Database Design
The project utilizes a relational schema joined on the `order_id` and `date` keys:
* **Customer Table:** Demographics, Acquisition Cost, Order Values.
* **Shipment Table:** Logistics routes, Freight Costs, Customs Data.
* **Logistics Table:** Daily operational metrics (Utilization, Delay Hours).

## 🚀 How to Run this Project
1.  Clone this repository.
2.  Execute `/sql/database_setup.sql` in your PostgreSQL environment.
3.  Import the provided CSV files into the staging tables.
4.  Connect Tableau to the `v_master_logistics_analytics` view.

### Featured SQL: 
```sql
-- Calculating Carrier Performance Score (CPS)
-- This query identifies which carriers offer the best balance 
-- of speed (Customs Clearance) vs. Cost-Effectiveness.

SELECT 
    l.carrier,
    COUNT(s.shipment_id) AS total_shipments,
    ROUND(AVG(s.freight_cost::NUMERIC), 2) AS avg_freight_cost,
    ROUND(AVG(s.customs_clearance_time_days::NUMERIC), 2) AS avg_clearance_days,
    ROUND(AVG(l.delay_hours_avg), 2) AS regional_delay_impact,
    -- Efficiency Score Formula: (Low Cost + Low Delay = High Score)
    ROUND(
        (1 / (AVG(s.freight_cost::NUMERIC) * AVG(s.customs_clearance_time_days::NUMERIC))) * 1000000, 
        2
    ) AS efficiency_rating
FROM shipment s
JOIN logistics_performance l ON s.origin = l.region AND s.date::DATE = l.date
GROUP BY l.carrier
ORDER BY efficiency_rating DESC;
