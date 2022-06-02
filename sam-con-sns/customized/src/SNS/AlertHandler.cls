/// An example Alert Handler class, which send the Alert to an AWS SNS Topic
/// extends %SAM.AbstractAlertsHandler
Class SNS.AlertHandler Extends %RegisteredObject
{

/// The AWS Region for the SNS Topic
Property AWSRegion As %String;

/// A User Programmatic Access Key with privileges to send 
Property AWSAccessKeyId As %String;

/// An SecretAccessKey for the user
Property AWSSecretAccessKey As %String;

/// The TopicArn for the messages
Property AWSTopicArn As %String;

/// The instantiated snsclient from boto3
Property snsclient;

/*
In AWS, we have created an SNS Topic, with a Subscriber in the sandbox, and a user with programatic access
and following Policy for this user:

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [ "sns:Publish" ],
            "Effect": "Allow",
            "Resource": "arn:aws:sns:eu-west-1:974893051747:AlertasSAM"
        }
    ]
}
*/

/*
HandleAlerts() method receives a %DynamicArray packet of alerts with the following format:

[
  {
    "labels":{
      "alertname":"High CPU Usage",
      "cluster":"1",
      "instance":"10.0.0.24:9092",
      "job":"SAM",
      "severity":"critical"
    },
    "annotations":{
      "description":"CPU usage exceeded the 95% threshold."
    },
    "ts": "2020-04-17 18:07:42.536"
  },
  {
    "labels":{
      "alertname":"iris_system_alert",
      "cluster":"1",
      "instance":"10.0.0.24:9092",
      "job":"SAM",
      "severity":"critical"
    },
    "annotations":{
      "description":"Previous system shutdown was abnormal, system forced down or crashed"
    },
    "ts":"2020-04-17 18:07:36.926"
  }
]
*/
/// 
/// HandlerAlerts() implements behaviour when an alert fires
/// You can use this handler to send messages using Telegram, email, etc.
/// 
ClassMethod HandleAlerts(packet As %DynamicArray) As %Status
{
    set iter = packet.%GetIterator()
    while iter.%GetNext(.idx, .alert) {
        set msg = alert.annotations.description
        if alert.labels.severity = "critical" {
            set severity = 2
        } else {
            set severity = 1
        }
        
        //do ##class(%SYS.System).WriteToConsoleLog(msg, 1, severity)
    }
    quit $$$OK
}

Method PyInit() [ Language = python ]
{
    import os
    
    self.AWSRegion=os.environ.get("AWS_REGION",self.AWSRegion)
    self.AWSAccessKeyId=os.environ.get("AWS_ACCESS_KEY_ID",self.AWSAccessKeyId)
    self.AWSSecretAccessKey=os.environ.get("AWS_SECRET_ACCESS_KEY",self.AWSSecretAccessKey)
    self.AWSTopicArn=os.environ.get("AWS_TOPIC_ARN",self.AWSTopicArn)
    #print(f"PyInit: Region: {self.AWSRegion}, Key: {self.AWSAccessKeyId}  Secret: {self.AWSSecretAccessKey} Topic: {self.AWSTopicArn}")
    
    import boto3
    self.snsclient=boto3.client("sns",region_name=self.AWSRegion, aws_access_key_id=self.AWSAccessKeyId,aws_secret_access_key=self.AWSSecretAccessKey)
}

Method SendSNS(subject, message) As %String [ Language = python ]
{
    
    try:
        response = self.snsclient.publish(
            TopicArn=self.AWSTopicArn,
            Message=message,
            Subject=subject,
        ) ['MessageId']
    except ClientError:
        print('Could not publish message to the topic.')
        raise
    else:
        return response
}

}
