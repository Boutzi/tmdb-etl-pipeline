SELECT
    id,
    title,
    original_title,
    original_language,
    overview,
    release_date,
    popularity,
    vote_average,
    vote_count,
    genre_ids
FROM {{ source('staging', 'movies') }}
WHERE title IS NOT NULL
QUALIFY ROW_NUMBER() OVER (PARTITION BY id ORDER BY vote_count DESC) = 1