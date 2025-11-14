CREATE TABLE coinx_table.dim_token AS
SELECT 
    token_id,
    token_name,
    category
FROM coinx_data_staging.stg_tokens;
