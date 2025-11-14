WITH
  user_activity AS ( -- P2P Send
  SELECT
    sender_id AS user_id,
    DATE(transfer_created_time) AS activity_date,
    'P2P_SEND' AS activity_type,
    token_id,
    amount AS volume_usd,
    1 AS transaction_count
  FROM
    coinx_table.fact_p2p_transfers p
  WHERE
    status = 'SUCCESS'
  UNION ALL
    -- P2P Receive
  SELECT
    receiver_id AS user_id,
    DATE(transfer_created_time) AS activity_date,
    'P2P_RECEIVE' AS activity_type,
    token_id,
    amount AS volume_usd,
    1 AS transaction_count
  FROM
    coinx_table.fact_p2p_transfers p
  WHERE
    status = 'SUCCESS'
  UNION ALL
    -- Trading
  SELECT
    user_id,
    DATE(trade_created_time) AS activity_date,
    'TRADE' || side AS activity_type,
    token_id,
    trade_value_usd AS volume_usd,
    1 AS transaction_count
  FROM
    coinx_table.fact_trades st
  WHERE
    status = 'FILLED' ),
  raw_data AS (
  SELECT
    DISTINCT a.user_id,
    region,
    signup_date,
    activity_date,
    activity_type,
    a.token_id,
    token_name,
    category AS token_category,
    volume_usd,
    transaction_count
  FROM
    user_activity a
  JOIN
    coinx_table.dim_user u
  ON
    u.user_id = a.user_id
  JOIN
    coinx_table.dim_token t
  ON
    t.token_id = a.token_id)
  -- user_first_activities AS (
  SELECT
    user_id,
    MIN(activity_date) AS first_activity_date,
    MIN(CASE
        WHEN activity_type LIKE 'P2P%' THEN activity_date
    END
      ) AS first_p2p_date,
    MIN(CASE
        WHEN activity_type LIKE 'TRADE%' THEN activity_date
    END
      ) AS first_trade_date,
    CASE
      WHEN MIN(CASE
        WHEN activity_type LIKE 'TRADE%' THEN activity_date
    END
      ) IS NOT NULL
    AND MIN(CASE
        WHEN activity_type LIKE 'TRADE%' THEN activity_date
    END
      ) >= MIN(CASE
        WHEN activity_type LIKE 'P2P%' THEN activity_date
    END
      ) THEN 'CONVERTED FROM P2P TO TRADE'
    WHEN MIN(CASE
        WHEN activity_type LIKE 'P2P%' THEN activity_date
    END
      ) IS NOT NULL
    AND MIN(CASE
        WHEN activity_type LIKE 'P2P%' THEN activity_date
    END
      ) >= MIN(CASE
        WHEN activity_type LIKE 'TRADE%' THEN activity_date
    END
      ) THEN 'CONVERTED FROM TRADE TO P2P'      
  END
    AS user_journey
  FROM
    user_activity
  GROUP BY
    user_id
--   1
