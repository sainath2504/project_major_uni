
# Banking Payments Analytics & AML Risk Dashboard (Major Project)

## Files
- `payments_data.csv`
- `aml_queries.sql`

## Load Steps (Power BI)
1) Get Data → Text/CSV → select `payments_data.csv`.
2) Ensure `timestamp` is Date/Time. Create a `Date` column if needed:
   - Transform Data → Add Column → Custom → Date.From([timestamp])
3) Create measures (Modeling → New Measure):
```
Total Transactions = COUNTROWS(payments_data)
Flagged Transactions = CALCULATE([Total Transactions], SUM(payments_data[flagged]) = 1)
% Flagged = DIVIDE([Flagged Transactions], [Total Transactions])

Total Value (CAD) = SUM(payments_data[amount_cad])
Flagged Value (CAD) = CALCULATE([Total Value (CAD)], SUM(payments_data[flagged]) = 1)

Daily Inflow (CAD) = 
SUMX(FILTER(payments_data, payments_data[receiver_country] = "CA"), payments_data[amount_cad])

Daily Outflow (CAD) = 
SUMX(FILTER(payments_data, payments_data[sender_country] = "CA"), payments_data[amount_cad])

Net Liquidity (CAD) = [Daily Inflow (CAD)] - [Daily Outflow (CAD)]
```

## Suggested Visuals
- KPI Cards: Total Transactions, % Flagged, Total Value (CAD), Flagged Value (CAD)
- Line: Daily Inflow, Outflow, Net Liquidity
- Bar: High-Risk Corridors (sender_country → receiver_country) by flagged txns
- Map: Receiver Country sized by Total Value (CAD); tooltip includes % Flagged
- Bar: Channel Mix (txns, % flagged)
- Matrix: Customer Segment × Risk Tier with % Flagged

## Filters for Analysts
- channel IN {SWIFT, WIRE}
- amount_cad >= 75000
- cross_border = 1
- receiver_country in high-risk list
