from datetime import date
from utils.fetch_data import fetch_data
from utils.s3_client import upload_to_s3
import time
from tqdm import tqdm

BASE_URL = "https://api.themoviedb.org/3"

genre_url = f"{BASE_URL}/genre/movie/list"
movies_url = f"{BASE_URL}/discover/movie"

def fetch_genres():
    return fetch_data(genre_url)

def fetch_movies():
    first_page = fetch_data(movies_url, {"page": 1})
    movies = first_page["results"]
    total_pages = first_page["total_pages"]
    for i in tqdm(range(1, min(total_pages, 500))):
        movies_raw = fetch_data(movies_url, {"page": i + 1})
        movies += movies_raw["results"]
        time.sleep(0.25)
    return movies

def upload_genres_wrapper():
    upload_to_s3(fetch_genres(), "tmdb-etl-raw-dev", f"genres/{date.today()}/genres.json")

def upload_movies_wrapper():
    upload_to_s3(fetch_movies(), "tmdb-etl-raw-dev", f"movies/{date.today()}/movies.json")

if __name__ == "__main__":
    upload_genres_wrapper()
    upload_movies_wrapper()