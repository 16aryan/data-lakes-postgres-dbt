{{ config( twin_strategy="allow", materialized="table" ) }}

WITH source_data AS (
    SELECT
        id,
        station_id,
        session_duration,
        energy_consumed_kWh,
        charging_rate,
        cost,
        CAST(start_time AS TIMESTAMP) AS start_time,
        CAST(end_time AS TIMESTAMP) AS end_time
    FROM {{ source("chargenet_bronze", "charging_sessions") }}
)

SELECT
    id,
    station_id,
    session_duration,
    energy_consumed_kWh,
    charging_rate,
    cost,
    start_time,
    end_time
FROM source_data
