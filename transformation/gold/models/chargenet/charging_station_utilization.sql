{% set nessie_branch = var('nessie_branch', 'main') %}

SELECT
    st.id as station_id,
    st.city,
    st.country,
    st.station_type,
    COUNT(cs.id) as total_sessions,
    AVG(cs.session_duration) as average_duration,
    SUM(cs.energy_consumed_kWh) as total_energy_consumed
FROM {{ source('silver', 'stations') }} st
LEFT JOIN {{ source('silver', 'charging_sessions') }} cs ON st.id = cs.station_id
GROUP BY st.id, st.city, st.country, st.station_type
