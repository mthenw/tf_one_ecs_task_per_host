import os
import boto3

autoscaling = boto3.client('autoscaling')
ecs = boto3.client('ecs')

def scale(event, context):
    response = autoscaling.describe_auto_scaling_groups(
        AutoScalingGroupNames=[
            os.environ['autoscaling_group_name'],
        ]
    )

    response = ecs.update_service(
        cluster=os.environ['ecs_cluster_name'],
        service=os.environ['ecs_service_name'],
        desiredCount=response['AutoScalingGroups'][0]['DesiredCapacity'],
    )

    return response['service']['desiredCount']