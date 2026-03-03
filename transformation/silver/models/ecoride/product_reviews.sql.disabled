{{ config( twin_strategy="allow", materialized="table" ) }}

WITH formatted_reviews AS (
    SELECT
        CAST(CustomerID AS INTEGER) AS customerid,
        CAST("Date" as DATE) as ReviewDate,
        CAST(Rating AS NUMERIC) AS rating,
        ReviewID as reviewid,
        TRIM(ReviewText) as ReviewText, -- Removes leading and trailing spaces
        VehicleModel as vehiclemodel
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