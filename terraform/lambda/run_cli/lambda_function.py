import time
import json
import boto3
import os

s3_destination_bucket = os.environ['S3BUCKET']
app_name = os.environ['APPNAME']

def lambda_handler(event, context):
    
    ===sanitized===
