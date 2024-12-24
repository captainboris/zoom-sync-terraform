import json
import os
import hmac
import hashlib
import requests
import boto3
from datetime import datetime, timedelta, timezone
import time

# Environment variables
ZOOM_WEBHOOK_SECRET_TOKEN = os.getenv('ZOOM_WEBHOOK_SECRET_TOKEN')
S3_BUCKET_NAME = os.getenv('S3_BUCKET_NAME')
SNS_TOPIC_ARN = os.getenv('SNS_TOPIC_ARN')
MONGODB_API_ENDPOINT = os.getenv('MONGODB_API_ENDPOINT')  # MongoDB API endpoint

# Initialize AWS clients
s3_client = boto3.client('s3')
sns_client = boto3.client('sns')

# Brisbane timezone offset (UTC+10, no daylight savings in Queensland)
BRISBANE_OFFSET = timezone(timedelta(hours=10))

def convert_to_brisbane_time(gmt_time):
    """
    Converts a GMT datetime string to Brisbane time.
    """
    start_time = time.time()
    gmt_datetime = datetime.strptime(gmt_time, "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=timezone.utc)
    brisbane_datetime = gmt_datetime.astimezone(BRISBANE_OFFSET)
    duration = time.time() - start_time
    print(f"convert_to_brisbane_time executed in {duration:.2f} seconds")
    return brisbane_datetime

def get_lesson_and_video_ids(object_id):
    """
    Retrieves lessonId and videoId from the MongoDB API.
    """
    start_time = time.time()
    try:
        response = requests.post(f"{MONGODB_API_ENDPOINT}/{object_id}")
        response.raise_for_status()
        data = response.json()
        lesson_id = data.get("lessonId")
        video_id = data.get("videoId")
        print(f"Successfully retrieved lessonId={lesson_id}, videoId={video_id}")
        duration = time.time() - start_time
        print(f"get_lesson_and_video_ids executed in {duration:.2f} seconds")
        return lesson_id, video_id
    except Exception as e:
        duration = time.time() - start_time
        print(f"get_lesson_and_video_ids failed in {duration:.2f} seconds")
        raise Exception(f"Failed to retrieve lessonId and videoId: {e}")

def file_exists_with_tag(bucket_name, tag):
    """
    Checks if a file exists in the S3 bucket with a specific tag.
    """
    start_time = time.time()
    try:
        paginator = s3_client.get_paginator('list_objects_v2')
        for page in paginator.paginate(Bucket=bucket_name):
            for obj in page.get('Contents', []):
                key = obj['Key']
                tagging = s3_client.get_object_tagging(Bucket=bucket_name, Key=key)
                tag_set = tagging.get('TagSet', [])
                if tag in tag_set:
                    print(f"File already exists with tag: {tag}")
                    return True
        duration = time.time() - start_time
        print(f"file_exists_with_tag executed in {duration:.4f} seconds")
        return False
    except Exception as e:
        duration = time.time() - start_time
        print(f"file_exists_with_tag failed in {duration:.4f} seconds")
        raise Exception(f"Error checking for file with tag: {e}")

def stream_video_to_s3(video_url, download_token, object_key, tag):
    """
    Streams video content from a URL and uploads it to S3, adding a single tag with video_info.
    Triggers SNS notification if the file size is smaller than 1MB.
    """
    try:
        start_time = time.time()
        headers = {"Authorization": f"Bearer {download_token}"}
        with requests.get(video_url, headers=headers, stream=True) as response:
            response.raise_for_status()
            s3_client.upload_fileobj(
                response.raw,
                S3_BUCKET_NAME,
                object_key,
                ExtraArgs={"ContentType": "video/mp4"}
            )
            response.raw.seek(0, os.SEEK_END)  # Get the size of the streamed content
            file_size = response.raw.tell()

            if file_size < 1 * 1024 * 1024:  # File size less than 1MB
                sns_client.publish(
                    TopicArn=SNS_TOPIC_ARN,
                    Message=f"File {object_key} uploaded to S3 is smaller than 1MB. Size: {file_size} bytes",
                    Subject="Small File Upload Alert"
                )

            s3_client.put_object_tagging(
                Bucket=S3_BUCKET_NAME,
                Key=object_key,
                Tagging={"TagSet": [tag]}
            )
            print(f"Successfully uploaded and tagged video: {object_key} with tag {tag}")
            duration = time.time() - start_time
            print(f"stream_video_to_s3 executed in {duration:.2f} seconds")
    except Exception as e:
        sns_client.publish(
            TopicArn=SNS_TOPIC_ARN,
            Message=f"Failed to upload video {object_key} to S3. Error: {str(e)}",
            Subject="Video Upload Failure Alert"
        )
        raise Exception(f"Failed to upload video to S3: {e}")

def lambda_handler(event, context):
    """
    Handles Zoom recording webhook events and uploads videos to S3.
    """
    print(f"Event received: {event}")
    errors = []  # List to store error messages
    skipped_files = []  # List to track skipped files
    
    try:
        if event.get('event') == "endpoint.url_validation":
            plain_token = event['payload']['plainToken']
            encrypted_token = hmac.new(
                ZOOM_WEBHOOK_SECRET_TOKEN.encode(),
                plain_token.encode(),
                hashlib.sha256
            ).hexdigest()
            return {
                "plainToken": plain_token,
                "encryptedToken": encrypted_token
            }

        elif event.get('event') == "recording.completed":
            payload = event['payload']
            object_id = payload['object']['id']
            topic = payload['object']['topic']
            start_time = payload['object']['start_time']
            recording_files = payload['object']['recording_files']
            download_token = event['download_token']

            brisbane_datetime = convert_to_brisbane_time(start_time)
            brisbane_time_formatted = brisbane_datetime.strftime("%Y_%m_%d_%H%M")

            video_files = [
                file for file in recording_files
                if file.get('file_type', '').lower() == 'mp4'
            ]

            if not video_files:
                print("No video files found in the payload.")
                return {"statusCode": 200, "body": json.dumps({"message": "No video files to process"})}

            part = 1  # Counter for part number
            for video_file in sorted(video_files, key=lambda x: x['recording_start']):
                download_url = video_file.get('download_url')
                recording_type = video_file.get('recording_type', 'unknown')

                if not download_url:
                    error_message = f"Skipping file without download URL: {video_file}"
                    print(error_message)
                    errors.append(error_message)
                    continue

                video_info_value = f"{brisbane_time_formatted}_{recording_type}_part{part}"
                tag = {"Key": "video_info", "Value": video_info_value}

                try:
                    if file_exists_with_tag(S3_BUCKET_NAME, tag):
                        print(f"File already exists with tag: {tag}")
                        skipped_files.append(f"lesson/unknown/unknown_part{part}.mp4")
                        part += 1
                        continue
                except Exception as e:
                    errors.append(f"Error checking file existence: {str(e)}")
                    continue

                try:
                    lesson_id, video_id = get_lesson_and_video_ids(object_id)
                except Exception as e:
                    errors.append(f"Error retrieving lesson/video IDs: {str(e)}")
                    continue

                s3_key = f"lesson/{lesson_id}/{video_id}.mp4"

                try:
                    stream_video_to_s3(download_url, download_token, s3_key, tag)
                    part += 1
                except Exception as e:
                    errors.append(f"Error uploading video to S3: {str(e)}")

            response_message = {
                "message": "Video files processed successfully" if not errors else "Processed with errors"}
        else:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Unsupported event type"})
            }
                
    except Exception as e:
        error_message = f"Error processing event: {e}"
        print(error_message)
        sns_client.publish(
            TopicArn=SNS_TOPIC_ARN,
            Message=error_message,
            Subject="Lambda Processing Error"
        )
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Internal server error", "details": str(e)})
        }
