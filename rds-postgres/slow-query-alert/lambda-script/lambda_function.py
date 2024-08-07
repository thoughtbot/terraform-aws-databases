import json
import boto3
import os
import datetime
from calendar import timegm


# Get SNS Topic ARN from Environment variables
notificationSNSTopicArn = os.environ['notificationSNSTopicArn']
metricName = os.environ['metricName']
metricNamespace = os.environ['metricNamespace']

# Get SNS resource using boto3
snsClient = boto3.client('sns')

cloudWatchLogsClient = boto3.client('logs')


def lambda_handler(event, context):

    # Extract Alarm name and subject from Alarm event

    alarmMessage = json.loads(event['Records'][0]['Sns']['Message'])
    alarmSubject = event['Records'][0]['Sns']['Subject']

    # Get metric filters for slowquery
    describeMetricFilterResponse = cloudWatchLogsClient.describe_metric_filters(
        limit = 1,
        metricName = metricName,
        metricNamespace = metricNamespace
    )

    metricFilter = describeMetricFilterResponse['metricFilters'][0]

    alarmTimestamp = datetime.datetime.strptime(alarmMessage['StateChangeTime'], '%Y-%m-%dT%H:%M:%S.%f+0000')

    startTimeStamp = alarmTimestamp - datetime.timedelta(minutes=3)

    # Get log stream message using log filter
    filterMetricLogsResponse = cloudWatchLogsClient.filter_log_events(
        logGroupName=metricFilter['logGroupName'],
        filterPattern=metricFilter['filterPattern'],
        startTime=(timegm(startTimeStamp.utctimetuple()) * 1000),
        endTime=(timegm(alarmTimestamp.utctimetuple()) * 1000),
        limit=1,
    )

    # Get sql query from log stream message
    sqlQuery = filterMetricLogsResponse['events'][0]['message']

    # Build SNS message with sql query string
    alarmNotificationMessage = alarmMessage['AlarmDescription'] +'\n'+ alarmMessage['NewStateReason'] +'\n' +'\n'+ "SQL Query => " + sqlQuery
    
    modifiedStateReason = alarmMessage['NewStateReason'] +'\n' +'\n'+ "SQL Query => " + sqlQuery
    
    alarmMessage['NewStateReason'] = modifiedStateReason

    # push message to SNS topic
    response = snsClient.publish(
        TopicArn=notificationSNSTopicArn,
        Message=json.dumps(alarmMessage),
        Subject=alarmSubject,
        MessageStructure='string',
    )
    
    print("Message published to sns sucessfully")
