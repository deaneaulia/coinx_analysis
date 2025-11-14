CREATE TABLE coinx_table.fact_trades AS
SELECT 
    trade_id,
    user_id,
    token_id,
    side,
    price_usd,
    quantity,
    price_usd * quantity AS trade_value_usd,
    status,
    trade_created_time,
    trade_updated_time
FROM coinx_data_staging.stg_trades;
