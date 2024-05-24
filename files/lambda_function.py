import json
import requests
import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError
import os

# Initialize the SES client
ses_client = boto3.client('ses', region_name='us-east-1')

# Retrieve email parameters from environment variables
SENDER = os.environ['SENDER']
RECIPIENTS = json.loads(os.environ['RECIPIENTS'])

# Retrieve the websites and names from environment variables
websites = json.loads(os.environ['WEBSITES'])

SUBJECT = "Website Status Alert"
CHARSET = "UTF-8"

# Use DynamoDB to store the status of the websites
dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('DYNAMODB_TABLE', 'website_status')
table = dynamodb.Table(table_name)

def send_email(subject, body):
    try:
        response = ses_client.send_email(
            Destination={
                'ToAddresses': RECIPIENTS,
            },
            Message={
                'Body': {
                    'Text': {
                        'Charset': CHARSET,
                        'Data': body,
                    },
                },
                'Subject': {
                    'Charset': CHARSET,
                    'Data': subject,
                },
            },
            Source=SENDER,
        )
    except (NoCredentialsError, PartialCredentialsError) as e:
        print(f"Error: {e}")
        return False
    return True

def lambda_handler(event, context):
    for website_name, url in websites.items():
        try:
            response = requests.get(url)
            status_code = response.status_code
        except requests.RequestException as e:
            status_code = None
            print(f"Error checking {url}: {e}")

        # Log the status code to CloudWatch Logs
        print(f"Website: {url}, Status Code: {status_code}")

        # Check the previous status from DynamoDB
        previous_status = get_previous_status(url)

        if not (200 <= status_code <= 302):
            if previous_status != 'down':
                # Send an email if the website is down
                subject = f"ALERT: Website {website_name} is DOWN!"
                body = f"Website {url} returned status code {status_code}. Please check immediately."
                send_email(subject, body)
                # Update the status in DynamoDB
                update_status(url, 'down')
        else:
            if previous_status == 'down':
                # Send an email if the website has come back up
                subject = f"INFO: Website {website_name} is BACK UP"
                body = f"Website {url} has returned to normal status with status code {status_code}."
                send_email(subject, body)
                # Update the status in DynamoDB
                update_status(url, 'up')

    return {
        'statusCode': 200,
        'body': json.dumps(f"Checked websites: {', '.join(websites.keys())}")
    }

def get_previous_status(url):
    try:
        response = table.get_item(Key={'url': url})
        if 'Item' in response:
            return response['Item']['status']
    except Exception as e:
        print(f"Error getting previous status for {url}: {e}")
    return None

def update_status(url, status):
    try:
        table.put_item(Item={'url': url, 'status': status})
    except Exception as e:
        print(f"Error updating status for {url}: {e}")
