-- ============================================================
-- TMDB ETL Pipeline — Snowflake Setup
-- ============================================================
-- Run each section sequentially.
-- Verification queries are included but optional.
-- ============================================================


-- ------------------------------------------------------------
-- 1. DATABASE & SCHEMAS
-- ------------------------------------------------------------

CREATE DATABASE tmdb_etl;

USE DATABASE tmdb_etl;

-- staging: raw data loaded from S3 processed bucket
-- analytics: transformed data modelled by dbt
CREATE SCHEMA staging;
CREATE SCHEMA analytics;


-- ------------------------------------------------------------
-- 2. STAGING TABLES
-- ------------------------------------------------------------

USE SCHEMA staging;

CREATE TABLE movies (
    id               INTEGER,
    title            STRING,
    original_title   STRING,
    original_language STRING,
    overview         STRING,
    release_date     DATE,
    popularity       FLOAT,
    vote_average     FLOAT,
    vote_count       INTEGER,
    genre_ids        ARRAY
);

CREATE TABLE genres (
    id   INTEGER,
    name STRING
);

-- Verify tables were created
SHOW TABLES IN SCHEMA staging;


-- ------------------------------------------------------------
-- 3. S3 STORAGE INTEGRATION
-- Run DESC after creation to retrieve:
--   - STORAGE_AWS_IAM_USER_ARN  → update IAM role trust policy Principal
--   - STORAGE_AWS_EXTERNAL_ID   → update IAM role trust policy Condition
-- ------------------------------------------------------------

CREATE STORAGE INTEGRATION tmdb_s3_integration
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = 'S3'
    ENABLED = TRUE
    STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::<AWS_ACCOUNT_ID>:role/tmdb-etl-snowflake-role'
    STORAGE_ALLOWED_LOCATIONS = ('s3://tmdb-etl-processed-dev/');

DESC INTEGRATION tmdb_s3_integration;

-- ------------------------------------------------------------
-- 4. EXTERNAL STAGE
-- Points to the processed S3 bucket using the storage integration
-- ------------------------------------------------------------

CREATE FILE FORMAT parquet_format
    TYPE = PARQUET;

CREATE STAGE tmdb_etl.staging.tmdb_processed_stage
    STORAGE_INTEGRATION = tmdb_s3_integration
    URL = 's3://tmdb-etl-processed-dev/'
    FILE_FORMAT = (TYPE = PARQUET);

-- Verify Snowflake can list files in the bucket
LIST @tmdb_etl.staging.tmdb_processed_stage;


-- ------------------------------------------------------------
-- 5. LOAD DATA INTO STAGING TABLES
-- ------------------------------------------------------------

-- Movies: load all Parquet files from the movies/ prefix
COPY INTO tmdb_etl.staging.movies
FROM @tmdb_etl.staging.tmdb_processed_stage/movies/
FILE_FORMAT = (TYPE = PARQUET)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

-- Genres: the Parquet file stores all genres as a nested array
-- FLATTEN is required to explode the array into individual rows
-- Note: replace the filename with the actual Parquet file name from LIST output

TRUNCATE TABLE tmdb_etl.staging.genres; -- Delete all rows from table (if needed)

INSERT INTO tmdb_etl.staging.genres (id, name)
SELECT
    value:id::INTEGER,
    value:name::STRING
FROM @tmdb_etl.staging.tmdb_processed_stage/genres/run-1780235359097-part-block-0-r-00000-snappy.parquet
(FILE_FORMAT => parquet_format),
LATERAL FLATTEN(input => $1:genres);


-- ------------------------------------------------------------
-- 6. VERIFICATION
-- ------------------------------------------------------------

SELECT * FROM tmdb_etl.staging.movies LIMIT 5;
SELECT * FROM tmdb_etl.staging.genres;