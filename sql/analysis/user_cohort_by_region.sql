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
    t.token_id = a.token_id),
     cohort_base AS (
  SELECT 
    user_id,
    region,
    DATE_TRUNC(DATE(MIN(activity_date)), MONTH) AS cohort_month
  FROM raw_data
  GROUP BY user_id, region
),

monthly_activity AS (
  SELECT 
    user_id,
    region,
    DATE_TRUNC(DATE(activity_date), MONTH) AS activity_month
  FROM raw_data
  GROUP BY user_id, region, activity_month
),

cohort_analysis AS (
  SELECT 
    cb.cohort_month,
    cb.region,
    ma.activity_month,
    DATE_DIFF(ma.activity_month, cb.cohort_month, MONTH) AS month_number,
    cb.user_id
  FROM cohort_base cb
  JOIN monthly_activity ma ON cb.user_id = ma.user_id AND cb.region = ma.region
),

cohort_summary AS (
  SELECT 
    cohort_month,
    region,
    month_number,
    COUNT(DISTINCT user_id) AS active_users
  FROM cohort_analysis
  GROUP BY cohort_month, region, month_number
),

cohort_sizes AS (
  SELECT 
    cohort_month,
    region,
    COUNT(DISTINCT user_id) AS total_cohort_size
  FROM cohort_base
  GROUP BY cohort_month, region
)

SELECT 
  cs.cohort_month,
  cs.region,
  cs.total_cohort_size,
  ca.month_number,
  ca.active_users,
  ROUND(ca.active_users * 100.0 / cs.total_cohort_size, 2) AS retention_rate
FROM cohort_summary ca
JOIN cohort_sizes cs ON ca.cohort_month = cs.cohort_month AND ca.region = cs.region
WHERE ca.month_number >= 0
ORDER BY cs.cohort_month, cs.region, ca.month_number;
