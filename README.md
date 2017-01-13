# tf\_one\_ecs\_task\_per\_host

Terraform module for autoscaling AWS ECS service based on number of instance is autoscaling group.

## Usage

    module "consul_service" {
      source = "github.com/mthenw/tf_one_ecs_task_per_host"

      name                   = "consul"
      autoscaling_group_name = "ecs_asg"
      ecs_cluster_name       = "prod"
      ecs_service_name       = "consul"
    }


## Inputs

| Name | Description | Default | Required |
|------|-------------|:-----:|:-----:|
| name | Name for resources (aws_sns_topic, aws_iam_role, aws_lambda_function) | - | yes |
| autoscaling_group_name | Name of autoscaling group | - | yes |
| ecs_cluster_name | Name of ECS cluster | - | yes |
| ecs_service_name | Name of ECS service to scale | - | yes |

