import boto3
import json
from datetime import datetime
import pymssql
import logging
import os
import boto3
import json

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('pw-amcs-audit-table')

def lambda_handler(event, context):
    workflow_id = event['workflowID']
    
    # Determine if it's a start, update, or end event
    if 'workflow_start_time' in event:
        # Start event
        item = {
            'workflow_id': workflow_id,
            'workflow_name': event['workflowName'],
            'workflow_start_time': event['workflow_start_time'],
            'lambda_function_name': '',
            'schema_list': '',
            'gluejob_name': '',
            'start_time': '',
            'end_time': '',
            'workflow_end_time': '',
            'workflow_status': ''
        }
        table.put_item(Item=item)
    
    elif 'lambda_function_name' in event:
        # Update lambda details
        update_expression = "SET lambda_function_name = :lf, schema_list = :sl"
        expression_attribute_values = {
            ':lf': event['lambda_function_name'],
            ':sl': json.dumps(event['schema_list'])
        }
        table.update_item(
            Key={'workflow_id': workflow_id},
            UpdateExpression=update_expression,
            ExpressionAttributeValues=expression_attribute_values
        )

    elif 'gluejob_name' in event:
        # Update glue job details
        update_expression = "SET gluejob_name = :gj, start_time = :st, end_time = :et"
        expression_attribute_values = {
            ':gj': event['gluejob_name'],
            ':st': event['start_time'],
            ':et': event['end_time']
        }
        table.update_item(
            Key={'workflow_id': workflow_id},
            UpdateExpression=update_expression,
            ExpressionAttributeValues=expression_attribute_values
        )

    elif 'workflow_end_time' in event:
        # End event
        update_expression = "SET workflow_end_time = :we, workflow_status = :ws"
        expression_attribute_values = {
            ':we': event['workflow_end_time'],
            ':ws': event['workflow_status']
        }
        table.update_item(
            Key={'workflow_id': workflow_id},
            UpdateExpression=update_expression,
            ExpressionAttributeValues=expression_attribute_values
        )

    return {
        'statusCode': 200,
        'body': json.dumps('Audit entry processed')
    }
