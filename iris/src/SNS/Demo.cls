Class SNS.Demo Extends %RegisteredObject
{

Property AWSRegion As %String [ InitialExpression = "eu-west-1" ];

Property AWSAccessKeyId As %String;

Property AWSSecretAccessKey As %String;

Property AWSTopicArn As %String [ InitialExpression = "arn:aws:sns:eu-west-1:974893051747:AlertasSAM" ];

/// Called when Object gets Instantiated.
/// Runs the Python code to read environment variables 
Method %OnNew() As %Status
{
    #DIM tSC as %Status=$$$OK
    try {
        Write "%OnNew()...",!
        do ..PyInit()
    }catch (ex) {
        set tSC=ex.AsStatus()
    }
    quit tSC
}

Method PyInit() [ Language = python ]
{
    import os
    
    self.AWSRegion=os.environ.get("AWS_REGION",self.AWSRegion)
    self.AWSAccessKeyId=os.environ.get("AWS_ACCESS_KEY_ID",self.AWSAccessKeyId)
    self.AWSSecretAccessKey=os.environ.get("AWS_SECRET_ACCESS_KEY",self.AWSSecretAccessKey)
    self.AWSTopicArn=os.environ.get("AWS_TOPIC_ARN",self.AWSTopicArn)
    print(f"PyInit: Region: {self.AWSRegion}, Key: {self.AWSAccessKeyId}  Secret: {self.AWSSecretAccessKey} Topic: {self.AWSTopicArn}")
}

Method SendSNS(subject, message) As %String [ Language = python ]
{
    import boto3
    sns_client=boto3.client("sns",region_name=self.AWSRegion, aws_access_key_id=self.AWSAccessKeyId,aws_secret_access_key=self.AWSSecretAccessKey)
    try:
        response = sns_client.publish(
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
