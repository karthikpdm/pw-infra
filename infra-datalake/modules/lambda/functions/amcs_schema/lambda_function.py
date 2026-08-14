import boto3
import json
import os
from datetime import datetime

# Create an S3 client
s3_client = boto3.client('s3')

def count(output_list):
    execution_times = []
    for item in output_list:
        # Extract the execution time, remove the ' min' part and convert to float
        execution_time = item.get('execution_time', '')
        if execution_time:
            # Remove the ' min' and convert the remaining part to float
            execution_time_value = float(execution_time.replace(' min', '').strip())
            execution_times.append(execution_time_value)

    # Step 2: Find the highest execution time
    max_execution_time = max(execution_times)

    # Step 3: Add 5 to the highest execution time
    return max_execution_time + 5

def convert_float_to_hms(time_in_minutes):
    # Extract the integer part as minutes
    minutes = int(time_in_minutes)
    
    # Extract the decimal part and convert to seconds
    seconds = (time_in_minutes - minutes) * 60
    seconds = round(seconds)  # Round to avoid floating point precision issues
    
    # Calculate hours from the total minutes
    hours = minutes // 60
    minutes = minutes % 60  # Remaining minutes after extracting hours
    
    # Format hours, minutes, and seconds as hh:mm:ss
    time_str = f"{hours:02d}:{minutes:02d}:{seconds:02d}"
    return time_str

def lambda_handler(event, context):
    try:
        current_date = datetime.now().strftime('%Y-%m-%d')
        # S3 bucket and folder path
        bucket_name = os.getenv('bucket')
        prefix = os.getenv('prefix')


        # Initialize the output list
        output_list = []
        output_string=''

        # List objects in the specified S3 folder
        response = s3_client.list_objects_v2(Bucket=bucket_name, Prefix=prefix)

        # Check if the response contains objects
        if 'Contents' in response:
            for obj in response['Contents']:
                # Get the file key (name)
                file_key = obj['Key']

                # Read each JSON file content
                file_content = s3_client.get_object(Bucket=bucket_name, Key=file_key)
                file_body = file_content['Body'].read().decode('utf-8')

                # Check if the file body is not empty before attempting to parse
                if file_body.strip():  # Only proceed if the content is not empty
                    try:
                        json_content = json.loads(file_body)
                        # Instead of using json.dumps(), directly append the content as a string
                        #output_string += str(json_content)  # This appends the content as a string
                        output_list.append(json_content)
                        print(output_list)
                        json_string = json.dumps(output_list)
                        sftime=count(output_list)
                        print(sftime)
                        response = {
                                      'time': convert_float_to_hms(sftime),
                                      'counts': json_string
                                    }
                    except json.JSONDecodeError as e:
                        # Handle error if JSON is malformed
                        print(f"Error decoding JSON in file {file_key}: {e}")
                else:
                    print(f"File {file_key} is empty.")

        

        # Return the formatted response as a plain string (not JSON)
        return {
            'statusCode': 200,
            'body': response
        }

    except Exception as e:
        # Log the error
        print(f"Error: {str(e)}")

        return {
            'statusCode': 500,
            'body': str(e)
        }
