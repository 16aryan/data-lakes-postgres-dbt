{{ config( twin_strategy="allow", materialized="table" ) }}

SELECT
    CAST(id AS INTEGER) AS id,
    address,
    city,
    country,
    CAST(number_of_chargers AS INTEGER) AS number_of_chargers,
    operational_status,
    state,
    station_type
FROM {{ source('chargenet_bronze', 'stations') }}
