{% set nessie_branch = var('nessie_branch', 'main') %}

SELECT
    c.id as customer_id,
    c.first_name,
    c.email,
    SUM(s.sale_price) as total_spent,
    COUNT(s.id) as total_transactions,
    AVG(s.sale_price) as average_transaction_value
FROM {{ source('silver', 'customers') }} c
LEFT JOIN {{ source('silver', 'sales') }} s ON c.id = s.customer_id
GROUP BY c.id, c.first_name, c.email
