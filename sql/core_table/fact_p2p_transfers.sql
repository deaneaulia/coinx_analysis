CREATE TABLE coinx_table.fact_p2p_transfers AS
SELECT 
    transfer_id,
    sender_id,
    receiver_id,
    token_id,
    amount,
    status,
    transfer_created_time,
    transfer_updated_time
FROM coinx_data_staging.stg_p2p_transfers;
