WITH monthly_trade_value_per_token AS (
  SELECT 
    DATE_TRUNC(DATE(trade_created_time), MONTH) AS month_key,
    token_id,
    SUM(trade_value_usd) AS trade_value
  FROM coinx_table.fact_trades 
  WHERE status = 'FILLED'
  GROUP BY 1,2
),
proportion AS (
  SELECT 
    month_key,
    token_id,
    trade_value,
    100 * trade_value / SUM(trade_value) OVER (PARTITION BY month_key) AS pct_of_total_trade_value
  FROM monthly_trade_value_per_token
)
SELECT 
  month_key,
  pr.token_id,
  tkn.token_name,
  trade_value,
  pct_of_total_trade_value
FROM proportion pr
LEFT JOIN coinx_table.dim_token tkn
ON  pr. token_id = tkn.token_id
ORDER BY month_key ASC, pct_of_total_trade_value DESC;

-- SELECT 
--     DATE_TRUNC(DATE(trade_created_time), MONTH) AS month_key,
--     token_id,
--     SUM(trade_value_usd) AS trade_value
--   FROM coinx_table.fact_trades 
--   WHERE status = 'FILLED'
--   GROUP BY 1,2;

-- SELECT 
--     DATE_TRUNC(DATE(trade_created_time), MONTH) AS month_key,
--     -- token_id,
--     SUM(trade_value_usd) AS trade_value
--   FROM coinx_table.fact_trades 
--   WHERE status = 'FILLED'
--   GROUP BY 1;


