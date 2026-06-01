SELECT
    id,
    name
FROM {{ source("staging", "genres")}}
WHERE id IS NOT NULL AND name IS NOT NULL