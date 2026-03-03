SELECT
    v.id as vehicle_id,
    v.model_name,
    v.model_type,
    v.year,
    v.battery_capacity,
    v.range,
    COUNT(s.sales_id) as total_sales
FROM {{ source('silver', 'vehicles') }} v
LEFT JOIN {{ source('silver', 'sales') }} s ON v.id = s.vehicle_id
GROUP BY v.id, v.model_name, v.model_type, v.year, v.battery_capacity, v.range
