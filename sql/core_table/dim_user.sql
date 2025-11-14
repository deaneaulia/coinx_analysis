CREATE TABLE coinx_table.dim_user AS
SELECT 
    user_id,
    region,
    signup_date
    -- DATE_TRUNC(CAST(signup_date AS DATE), MONTH) AS signup_month
FROM coinx_data_staging.stg_users;
