SELECT
    s.sales_id,
    s.customer_id,
    s.vehicle_id,
    s.sale_date,
    s.amount,
    s.status,
    c.name as customer_name,
    v.model_name as vehicle_model
FROM {{ source('silver', 'sales') }} s
LEFT JOIN {{ source('silver', 'customers') }} c ON s.customer_id = c.customer_id
LEFT JOIN {{ source('silver', 'vehicles') }} v ON s.vehicle_id = v.id
