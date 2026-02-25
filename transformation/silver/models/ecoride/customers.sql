{{ config( twin_strategy="allow", materialized="table" ) }}

SELECT
    CAST(id AS INTEGER) AS id,
    first_name,
    -- Assuming email is important and retained
    email,
    city,
    "state",
    country
FROM {{ source("ecoride_bronze", "customers") }}