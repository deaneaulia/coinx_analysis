CREATE TABLE coinx_data_staging.stg_trades AS
SELECT 
    trade_id,
    user_id,
    token_id,
    side,
    SAFE_CAST(price_usd AS NUMERIC) AS price_usd,
    SAFE_CAST(quantity AS NUMERIC) AS quantity,
    status,
    SAFE_CAST(trade_created_time AS TIMESTAMP) AS trade_created_time,
    SAFE_CAST(trade_updated_time AS TIMESTAMP) AS trade_updated_time
FROM coinx_data.raw_trades;
