from airflow import DAG
from datetime import datetime
from airflow.providers.amazon.aws.operators.glue import GlueJobOperator
from airflow.providers.amazon.aws.operators.glue_crawler import GlueCrawlerOperator
from airflow.providers.standard.operators.python import PythonOperator
from etl.extract.tmdb_client import upload_movies_wrapper, upload_genres_wrapper

with DAG(
    dag_id="tmdb_pipeline",
    start_date=datetime(2026, 5, 31),
    schedule="0 0 */3 * *",
) as dag:
    extract_genres = PythonOperator(
        task_id="extract_genres",
        python_callable=upload_genres_wrapper
    )
    extract_movies = PythonOperator(
        task_id="extract_movies",
        python_callable=upload_movies_wrapper
    )
    run_crawler = GlueCrawlerOperator(
        task_id="transform_genres",
        aws_conn_id="aws_default",
        config={"Name": "tmdb-etl-raw-crawler"}
    )
    glue_job_genres = GlueJobOperator(
        task_id="load_genres",
        aws_conn_id="aws_default",
        job_name="tmdb-etl-job-genres",
    )
    glue_job_movies = GlueJobOperator(
        task_id="load_movies",
        aws_conn_id="aws_default",
        job_name="tmdb-etl-glue-job",
    )
    extract_genres >> extract_movies >> run_crawler >> [glue_job_movies, glue_job_genres]