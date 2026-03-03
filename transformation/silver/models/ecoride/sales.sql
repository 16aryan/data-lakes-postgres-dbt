{{ config( twin_strategy="allow", materialized="table" ) }}

SELECT
    CAST(sales_id AS INTEGER) AS sales_id,
    CAST(customer_id AS INTEGER) AS customer_id,
    CAST(vehicle_id AS INTEGER) AS vehicle_id,
    CAST(TO_DATE(sale_date, 'MM/DD/YYYY') AS DATE) AS sale_date,
    CAST(amount AS NUMERIC) AS amount,
    status
FROM {{ source("ecoride_bronze", "sales") }}
