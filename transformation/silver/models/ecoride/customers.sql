{{ config( twin_strategy="allow", materialized="table" ) }}

SELECT
    CAST(customer_id AS INTEGER) AS customer_id,
    name,
    email,
    city,
    state
FROM {{ source("ecoride_bronze", "customers") }}