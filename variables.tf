variable "name" {
  description = "Name for resources (aws_sns_topic, aws_iam_role, aws_lambda_function)"
}

variable "autoscaling_group_name" {
  description = "Name of autoscaling group"
}

variable "ecs_cluster_name" {
  description = "Name of ECS cluster"
}

variable "ecs_service_name" {
  description = "Name of ECS service to scale"
}
