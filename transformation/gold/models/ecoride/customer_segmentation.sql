{% set nessie_branch = var('nessie_branch', 'main') %}

SELECT
    c.id as customer_id,
    c.first_name,
    c.email,
    c.city,
    c.state,
    c.country,
    COUNT(s.id) as total_purchases,
    AVG(s.sale_price) as average_purchase_value,
    STRING_AGG(DISTINCT v.model_name, ', ') as preferred_models
FROM {{ source('silver', 'customers') }} c
LEFT JOIN {{ source('silver', 'sales') }} s ON c.id = s.customer_id
LEFT JOIN {{ source('silver', 'vehicles') }} v ON s.vehicle_id = v.id
GROUP BY c.id, c.first_name, c.email, c.city, c.state, c.country
