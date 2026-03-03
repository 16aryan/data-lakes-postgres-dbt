{% set nessie_branch = var('nessie_branch', 'main') %}

SELECT
    VehicleID,
    Model,
    ManufacturingYear,
    Alerts,
    MaintenanceHistory
FROM {{ source('silver', 'vehicle_health_logs') }}
