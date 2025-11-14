WITH
  user_trade_value AS (
  SELECT
    user_id,
    COUNT(DISTINCT token_id) AS count_tokens,
    SUM(trade_value_usd) AS total_trade_value
  FROM
    coinx_table.fact_trades
  WHERE
    status = 'FILLED'
  GROUP BY
    user_id
  ORDER BY
    3 DESC )
SELECT
  user_id,
  total_trade_value,
  SUM(total_trade_value) OVER (ORDER BY total_trade_value DESC) / SUM(total_trade_value) OVER () AS cumulative_pct
FROM
  user_trade_value
ORDER BY
  2 DESC
