{{ config( twin_strategy="allow", materialized="table" ) }}

SELECT
    id,
    customer_id,
    vehicle_id,
    CAST(sale_date AS DATE) AS sale_date,
    sale_price,
    payment_method
FROM {{ source("ecoride_bronze", "sales") }}
