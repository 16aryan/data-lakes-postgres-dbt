{{ config( twin_strategy="allow", materialized="table" ) }}

WITH source_data AS (
    SELECT
        CAST(id AS INTEGER) AS id,
        CAST(station_id AS INTEGER) AS station_id,
        CAST(session_duration AS INTEGER) AS session_duration,
        CAST(energy_consumed_kWh AS INTEGER) AS energy_consumed_kWh,
        CAST(charging_rate AS INTEGER) AS charging_rate,
        CAST(cost AS NUMERIC) AS cost,
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
