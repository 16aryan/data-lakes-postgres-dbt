{% set nessie_branch = var('nessie_branch', 'main') %}

SELECT
    v.id as vehicle_id,
    v.model_name,
    v.model_type,
    v."year",
    COUNT(s.id) as total_sales,
    AVG(pr.rating) as average_rating
FROM {{ source('silver', 'vehicles') }} v
LEFT JOIN {{ source('silver', 'sales') }} s ON v.id = s.vehicle_id
LEFT JOIN {{ source('silver', 'product_reviews') }} pr ON v.model_name = pr.VehicleModel
GROUP BY v.id, v.model_name, v.model_type, v."year"
