import os
import boto3

autoscaling = boto3.client('autoscaling')
ecs = boto3.client('ecs')

def scale(event, context):
    desired_count = autoscaling.describe_auto_scaling_groups(
        AutoScalingGroupNames=[
            os.environ['autoscaling_group_name'],
        ]
    )['AutoScalingGroups'][0]['DesiredCapacity']

    print "Updating '{}' service (cluster '{}') desired count to {}".format(
        os.environ['ecs_service_name'],
        os.environ['ecs_cluster_name'],
        desired_count,
    )

    response = ecs.update_service(
        cluster=os.environ['ecs_cluster_name'],
        service=os.environ['ecs_service_name'],
        desiredCount=desired_count,
    )

    return response['service']['desiredCount']