SELECT
    c.customer_id,
    c.name,
    c.email,
    SUM(s.amount) as total_spent,
    COUNT(s.sales_id) as total_transactions,
    AVG(s.amount) as average_transaction_value
FROM {{ source('silver', 'customers') }} c
LEFT JOIN {{ source('silver', 'sales') }} s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.name, c.email
