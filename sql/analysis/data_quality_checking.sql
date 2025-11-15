
SELECT
  'P2P_TRANSFERS' AS table_name,
  COUNT(*) AS total_records,
  COUNT(DISTINCT transfer_id) AS unique_ids,
  SUM(CASE
      WHEN status NOT IN ('SUCCESS', 'FAILED') THEN 1
      ELSE 0
  END
    ) AS invalid_statuses,
  SUM(CASE
      WHEN amount > ( SELECT AVG(amount) + 3 * STDDEV(amount) FROM coinx_table.fact_p2p_transfers WHERE amount IS NOT NULL ) THEN 1
      ELSE 0
  END
    ) AS suspicious_transfers,
  MIN(transfer_created_time) AS earliest_timestamp,
  MAX(transfer_created_time) AS latest_timestamp
FROM
  coinx_table.fact_p2p_transfers
UNION ALL
SELECT
  'TRADES' AS table_name,
  COUNT(*) AS total_records,
  COUNT(DISTINCT trade_id) AS unique_ids,
  SUM(CASE
      WHEN status NOT IN ('FILLED', 'FAILED') THEN 1
      ELSE 0
  END
    ) AS invalid_statuses,
  SUM(CASE
      WHEN trade_value_usd > ( SELECT AVG(trade_value_usd) + 3 * STDDEV(trade_value_usd) FROM coinx_table.fact_trades WHERE trade_value_usd IS NOT NULL ) THEN 1
      ELSE 0
  END
    ) AS suspicious_trades,
  MIN(trade_created_time) AS earliest_timestamp,
  MAX(trade_created_time) AS latest_timestamp
FROM
  coinx_table.fact_trades
