CREATE TABLE coinx_data_staging.stg_p2p_transfers AS
SELECT 
    transfer_id,
    sender_id,
    receiver_id,
    token_id,
    SAFE_CAST(amount AS NUMERIC) AS amount,
    status,
    SAFE_CAST(transfer_created_time AS TIMESTAMP) AS transfer_created_time,
    SAFE_CAST(transfer_updated_time AS TIMESTAMP) AS transfer_updated_time
    -- DATE_TRUNC('month', CAST(transfer_created_time AS TIMESTAMP)) AS transfer_month
FROM coinx_data.raw_p2p_transfers;
