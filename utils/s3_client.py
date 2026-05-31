from dotenv import load_dotenv
import boto3
import json

load_dotenv()

s3 = boto3.client("s3")

def upload_to_s3(data, bucket, key):
    if isinstance(data, list):
        s3.put_object(Body="\n".join(json.dumps(item) for item in data), Bucket=bucket, Key=key)
    elif isinstance(data, dict):
        s3.put_object(Body=json.dumps(data), Bucket=bucket, Key=key)
    else:
        print("Unsupported data type")