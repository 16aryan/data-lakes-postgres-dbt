{{ config( twin_strategy="allow", materialized="table" ) }}

SELECT
    CAST(id AS INTEGER) AS id,
    CAST(customer_id AS INTEGER) AS customer_id,
    CAST(vehicle_id AS INTEGER) AS vehicle_id,
    CAST(sale_date AS DATE) AS sale_date,
    CAST(sale_price AS NUMERIC) AS sale_price,
    payment_method
FROM {{ source("ecoride_bronze", "sales") }}
