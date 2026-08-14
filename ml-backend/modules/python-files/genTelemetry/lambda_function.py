import boto3
import json
import os
from botocore.exceptions import ClientError
from decimal import Decimal
# AWS Clients
location_service = boto3.client('location')
dynamodb = boto3.resource('dynamodb')
vehicle_table = dynamodb.Table(os.environ['DYNAMODB_TABLE_NAME'])

def lambda_handler(event, context):
    print("Received event:", json.dumps(event))
    try:
        # Extract telemetry data from the event
        vin = event['VIN']
        timestamp = event['timestamp']
        location_data = event['location']
        latitude = location_data['lat']
        longitude = location_data['long']

        # Additional vehicle data
        accuracy = event['accuracy']['Horizontal']
        heading = event['heading']
        speed = event['speed']
        battery_voltage = event['batteryVoltage']
        battery_soc = event['batterySOC']

        # Update device position in AWS Location Service
        tracker_name = os.environ['TRACKER']
        device_id = vin

        response = location_service.batch_update_device_position(
            TrackerName=tracker_name,
            Updates=[
                {
                    'DeviceId': device_id,
                    'Position': [longitude, latitude],
                    'SampleTime': timestamp
                }
            ]
        )
        print("Location data sent successfully to Tracker:", response)

        # Upload vehicle data to DynamoDB
        vin = event['VIN']
        timestamp = event['timestamp']
        location_data = event['location']
        latitude = Decimal(str(location_data['lat']))  # Convert to Decimal
        longitude = Decimal(str(location_data['long']))  # Convert to Decimal

        # Additional vehicle data
        accuracy = Decimal(str(event['accuracy']['Horizontal']))  # Convert to Decimal
        heading = Decimal(str(event['heading']))  # Convert to Decimal
        speed = Decimal(str(event['speed']))  # Convert to Decimal
        battery_voltage = Decimal(str(event['batteryVoltage']))  # Convert to Decimal
        battery_soc = Decimal(str(event['batterySOC']))  # Convert to Decimal
        dynamodb_item = {
            'VIN': vin,
            'timestamp': timestamp,
            'latitude': latitude,
            'longitude': longitude,
            'accuracy': accuracy,
            'heading': heading,
            'speed': speed,
            'batteryVoltage': battery_voltage,
            'batterySOC': battery_soc
        }

        # Put the item into the DynamoDB table
        vehicle_table.put_item(Item=dynamodb_item)
        print("Vehicle data uploaded successfully to DynamoDB.")


        return {
            'statusCode': 200,
            'body': json.dumps('Location data processed and uploaded successfully!')
        }

    except KeyError as e:
        print(f"Missing key in event data: {e}")
        return {
            'statusCode': 400,
            'body': json.dumps(f"Error: Missing key {e}")
        }
    except ClientError as e:
        print(f"Client error occurred: {e.response['Error']['Message']}")
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error: {e.response['Error']['Message']}")
        }
    except Exception as e:
        print(f"Error processing telemetry data: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error: {str(e)}")
        }
