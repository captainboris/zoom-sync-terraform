import json
import boto3
import os

s3 = boto3.client('s3')
sns = boto3.client('sns')

def handler(event, context):
    # 从事件中提取信息
    file_url = event['file_url']
    bucket_name = os.getenv('S3_BUCKET_NAME')
    sns_topic_arn = os.getenv('SNS_TOPIC_ARN')

    # 模拟下载和上传操作
    try:
        # 在这里执行文件下载和上传到 S3 的逻辑
        print(f"Downloading file from {file_url} and uploading to bucket {bucket_name}")

        # 上传成功后的逻辑
        print("File uploaded successfully.")

    except Exception as e:
        print(f"Error: {str(e)}")
        sns.publish(
            TopicArn=sns_topic_arn,
            Subject='Lambda Function Error',
            Message=str(e)
        )
