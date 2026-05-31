import os
from dotenv import load_dotenv
import requests

load_dotenv()

def fetch_data(url, params=None):
    headers = {
        "accept": "application/json",
        "Authorization": f"Bearer {os.environ.get('TMDB_READ_ACCESS_TOKEN')}"
    }
    response = requests.get(url, headers=headers, params=params)
    return response.json()