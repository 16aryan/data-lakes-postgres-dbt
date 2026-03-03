{{ config( twin_strategy="allow", materialized="table" ) }}

SELECT
    CAST(id AS INTEGER) AS id,
    model_name,
    model_type,
    battery_capacity,
    range,
    color,
    CAST(year AS INTEGER) AS year,
    CAST(charging_time AS INTEGER) AS charging_time
FROM {{ source("ecoride_bronze", "vehicles") }}