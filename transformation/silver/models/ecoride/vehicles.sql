{{ config( twin_strategy="allow", materialized="table" ) }}

SELECT
    CAST(id AS INTEGER) AS id,
    model_name,
    model_type,
    color,
    CAST("year" AS INTEGER) AS "year"
FROM {{ source("ecoride_bronze", "vehicles") }}