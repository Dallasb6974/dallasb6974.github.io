/* Project: Predictive Logistics & Supply Chain Pipeline
   Author: Dallas Brown
   Description: This script initializes the database schema, 
                handles data type casting, and creates 
                analytical views for Tableau.
*/

-- 1. Create Staging Tables (Optimized for CSV Import)
DROP TABLE IF EXISTS customer;
CREATE TABLE customer (
    customer_id TEXT, acquisition_date TEXT, acquisition_cost_usd TEXT,
    market_segment TEXT, supplier_id TEXT, order_id TEXT,
    order_date TEXT, order_value_usd TEXT, payment_date TEXT,
    satisfaction_score TEXT, support_tickets TEXT, lead_time_days TEXT
);

-- (Repeat for Shipment and Logistics_Performance tables)

-- 2. Data Cleaning & Alignment
-- Fixes column shift issues where D_Country was missing in original CSV
UPDATE shipment
SET 
    delivery_status = customs_clearance_time_days,
    customs_clearance_time_days = freight_cost,
    freight_cost = value,
    value = d_country,
    d_country = 'Singapore'
WHERE d_country ~ '^[0-9]+$';

-- 3. Create Analytical View for Tableau
CREATE OR REPLACE VIEW v_master_logistics_analytics AS
SELECT 
    c.customer_id,
    c.market_segment,
    c.order_value_usd::NUMERIC,
    s.shipment_id,
    s.freight_cost::NUMERIC,
    s.delivery_status,
    l.delay_hours_avg,
    (c.order_value_usd::NUMERIC - s.freight_cost::NUMERIC) AS estimated_profit
FROM customer c
JOIN shipment s ON c.order_id = s.shipment_id 
LEFT JOIN logistics_performance l ON s.date::DATE = l.date;