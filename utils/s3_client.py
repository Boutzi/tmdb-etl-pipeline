from dotenv import load_dotenv
import boto3
import json

load_dotenv()

s3 = boto3.client("s3")

def upload_to_s3(data, bucket, key):
    s3.put_object(Body=json.dumps(data), Bucket=bucket, Key=key)