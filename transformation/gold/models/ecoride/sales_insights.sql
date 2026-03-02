{% set nessie_branch = var('nessie_branch', 'main') %}

SELECT
    s.id as sale_id,
    s.customer_id,
    s.vehicle_id,
    s.sale_date,
    s.sale_price,
    s.payment_method,
    c.first_name as customer_name,
    v.model_name as vehicle_model
FROM {{ source('silver', 'sales') }} s
LEFT JOIN {{ source('silver', 'customers') }} c ON s.customer_id = c.id
LEFT JOIN {{ source('silver', 'vehicles') }} v ON s.vehicle_id = v.id
