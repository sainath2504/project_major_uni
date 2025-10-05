
-- AML & LIQUIDITY ANALYTICS SQL

-- 1) KPIs
SELECT
  COUNT(*) AS total_txns,
  SUM(CASE WHEN flagged=1 THEN 1 ELSE 0 END) AS flagged_txns,
  ROUND(100.0 * SUM(CASE WHEN flagged=1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_flagged,
  ROUND(SUM(amount_cad), 2) AS total_value_cad,
  ROUND(SUM(CASE WHEN flagged=1 THEN amount_cad ELSE 0 END), 2) AS flagged_value_cad
FROM payments_data;

-- 2) Liquidity by Day
WITH base AS (
  SELECT
    DATE(timestamp) AS d,
    SUM(CASE WHEN receiver_country='CA' THEN amount_cad ELSE 0 END) AS inflow_cad,
    SUM(CASE WHEN sender_country='CA' THEN amount_cad ELSE 0 END) AS outflow_cad
  FROM payments_data
  GROUP BY DATE(timestamp)
)
SELECT d,
       ROUND(inflow_cad,2) AS inflow_cad,
       ROUND(outflow_cad,2) AS outflow_cad,
       ROUND(inflow_cad - outflow_cad,2) AS net_liquidity_cad
FROM base
ORDER BY d;

-- 3) High-Risk Corridors
SELECT sender_country, receiver_country,
       COUNT(*) AS txns,
       ROUND(SUM(amount_cad),2) AS total_value_cad,
       SUM(flagged) AS flagged_txns
FROM payments_data
GROUP BY sender_country, receiver_country
ORDER BY flagged_txns DESC, total_value_cad DESC
LIMIT 50;

-- 4) Channel Mix & % Flagged
SELECT channel,
       COUNT(*) AS txns,
       ROUND(SUM(amount_cad),2) AS total_value_cad,
       ROUND(100.0 * SUM(flagged) / COUNT(*), 2) AS pct_flagged
FROM payments_data
GROUP BY channel
ORDER BY total_value_cad DESC;

-- 5) Customer Segment × Risk Tier
SELECT customer_segment, customer_risk_tier,
       COUNT(*) AS txns,
       ROUND(SUM(amount_cad),2) AS total_value_cad,
       ROUND(100.0 * SUM(flagged) / COUNT(*), 2) AS pct_flagged
FROM payments_data
GROUP BY customer_segment, customer_risk_tier
ORDER BY pct_flagged DESC;

-- 6) Top Receivers by Value (Potential Concentration Risk)
SELECT receiver_id,
       COUNT(*) AS txns,
       ROUND(SUM(amount_cad),2) AS total_value_cad,
       SUM(flagged) AS flagged_txns
FROM payments_data
GROUP BY receiver_id
ORDER BY total_value_cad DESC
LIMIT 50;
