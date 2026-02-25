{{ config( twin_strategy="allow", materialized="table" ) }}

WITH formatted_reviews AS (
    SELECT
        CAST(customerid AS INTEGER) AS customerid,
        CAST(reviewdate as DATE) as ReviewDate,
        CAST(rating AS NUMERIC) AS rating,
        reviewid,
        TRIM(reviewtext) as ReviewText, -- Removes leading and trailing spaces
        vehiclemodel
    FROM {{ source("ecoride_bronze", "product_reviews") }}
)

SELECT
    CustomerID,
    ReviewDate,
    Rating,
    ReviewID,
    ReviewText,
    VehicleModel
FROM formatted_reviews