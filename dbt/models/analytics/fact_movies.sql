SELECT
    m.id,
    m.title,
    m.original_language,
    m.release_date,
    m.popularity,
    m.vote_average,
    m.vote_count,
    g.name AS genre_name
FROM {{ ref('stg_movies') }} m,
LATERAL FLATTEN(input => m.genre_ids) f
JOIN {{ ref('dim_genres') }} g ON f.value::INTEGER = g.id