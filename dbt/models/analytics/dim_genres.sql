SELECT
    id,
    name
FROM {{ ref('stg_genres') }}