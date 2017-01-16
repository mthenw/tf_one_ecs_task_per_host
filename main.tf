/**
 *# tf\_one\_ecs\_task\_per\_host
 *
 *Terraform module for autoscaling AWS ECS service based on number of instance is autoscaling group.
 *
 *## Usage
 *
 *     module "consul_service" {
 *       source = "github.com/mthenw/tf_one_ecs_task_per_host"
 *
 *       name                   = "consul"
 *       autoscaling_group_name = "ecs_asg"
 *       ecs_cluster_name       = "prod"
 *       ecs_service_name       = "consul"
 *     }
 */

resource "aws_sns_topic" "topic" {
  name = "${var.name}"
}

resource "aws_autoscaling_notification" "notification" {
  group_names = [
    "${var.autoscaling_group_name}",
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
  ]

  topic_arn = "${aws_sns_topic.topic.arn}"
}

data "archive_file" "zip" {
  type        = "zip"
  source_file = "${path.module}/main.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_iam_role" "lambda" {
  name = "${var.name}_iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "role" {
  name = "as_ecs"
  role = "${aws_iam_role.lambda.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ecs:UpdateService"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "autoscaling:DescribeAutoScalingGroups"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_lambda_function" "lambda" {
  filename         = "${path.module}/lambda_function.zip"
  handler          = "main.scale"
  function_name    = "${var.name}"
  role             = "${aws_iam_role.lambda.arn}"
  runtime          = "python2.7"
  source_code_hash = "${base64sha256(file("${path.module}/lambda_function.zip"))}"

  environment {
    variables = {
      autoscaling_group_name = "${var.autoscaling_group_name}"
      ecs_cluster_name       = "${var.ecs_cluster_name}"
      ecs_service_name       = "${var.ecs_service_name}"
    }
  }
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda.arn}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.topic.arn}"
}

resource "aws_sns_topic_subscription" "subscription" {
  topic_arn = "${aws_sns_topic.topic.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.lambda.arn}"
}
