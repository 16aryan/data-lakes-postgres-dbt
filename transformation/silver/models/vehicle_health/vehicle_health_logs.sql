{{ config( twin_strategy="allow", materialized="table" ) }}

SELECT
    CAST(VehicleID AS VARCHAR) AS VehicleID,
    Model,
    CAST(ManufacturingYear AS INTEGER) AS ManufacturingYear,
    Alerts,
    MaintenanceHistory
FROM {{ source("vehicle_health_bronze", "logs") }}
