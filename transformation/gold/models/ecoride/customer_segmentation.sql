SELECT
    c.customer_id,
    c.name,
    c.email,
    c.city,
    c.state,
    COUNT(s.sales_id) as total_purchases,
    AVG(s.amount) as average_purchase_value,
    STRING_AGG(DISTINCT v.model_name, ', ') as preferred_models
FROM {{ source('silver', 'customers') }} c
LEFT JOIN {{ source('silver', 'sales') }} s ON c.customer_id = s.customer_id
LEFT JOIN {{ source('silver', 'vehicles') }} v ON s.vehicle_id = v.id
GROUP BY c.customer_id, c.name, c.email, c.city, c.state
