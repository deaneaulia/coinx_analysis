CREATE TABLE coinx_data_staging.stg_users AS
SELECT 
    user_id,
    region,
    CAST(signup_date AS DATE) AS signup_date
    -- DATE_TRUNC(CAST(signup_date AS DATE), MONTH) AS signup_month
FROM coinx_data.raw_users;
