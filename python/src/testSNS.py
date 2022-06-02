import os
import logging
import boto3
from botocore.exceptions import ClientError

###Define followin environment variables for the boto3 client
#AWS_REGION = "eu-west-1"
#AWS_ACCESS_KEY_ID=""
#AWS_SECRET_ACCESS_KEY=""
SNS_TOPIC_ARN='arn:aws:sns:eu-west-1:974893051747:AlertasSAM'

print ("Region:"+ os.environ["AWS_REGION"])
print ("AWS_ACCESS_KEY_ID:"+os.environ["AWS_ACCESS_KEY_ID"])

# logger config
logger= logging.getLogger()
logging.basicConfig(level=logging.INFO, format='%(asctime)s: %(levelname)s: %(message)s')

#Get an authenticated Session using shell environment variables

#session = boto3.Session(
#    aws_access_key_id=settings.AWS_SERVER_PUBLIC_KEY,
#    aws_secret_access_key=settings.AWS_SERVER_SECRET_KEY,
#)

sns_client = boto3.client("sns",region_name=os.environ["AWS_REGION"])
    #aws_access_key_id=,aws_secret_access_key='',
    

def publish_message(topic_arn,message,subject):
    """
    Publishes a message to a topic.
    """
    try:
        response = sns_client.publish(
            TopicArn=topic_arn,
            Message=message,
            Subject=subject,
        ) ['MessageId']
    except ClientError:
        logger.exception('Could not publish message to the topic.')
        raise
    else:
        return response


if __name__ == '__main__':

    topic_arn = SNS_TOPIC_ARN
    message = '...Message in a bottle'
    subject = 'From Python'

    logger.info(f'Publishing message to topic - {topic_arn}...')
    message_id = publish_message(topic_arn, message, subject)
    logger.info(
        f'Message published to topic - {topic_arn} with message Id - {message_id}.'
    )