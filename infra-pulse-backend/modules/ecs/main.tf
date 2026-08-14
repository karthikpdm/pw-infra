# Get the current AWS region
data "aws_region" "current" {}

# Get the current AWS account ID
data "aws_caller_identity" "current" {}
# Data sources for existing VPC components
data "aws_subnet" "private_subnet_az1" {
  filter {
    name   = "tag:Name"
    values = ["pw-private-subnet-az1-${var.env}"]
  }
}

data "aws_subnet" "private_subnet_az2" {
  filter {
    name   = "tag:Name"
    values = ["pw-private-subnet-az2-${var.env}"]
  }
}

data "aws_subnet" "public_subnet_az1" {
  filter {
    name   = "tag:Name"
    values = ["pw-public-subnet-az1-${var.env}"]
  }
}

data "aws_subnet" "public_subnet_az2" {
  filter {
    name   = "tag:Name"
    values = ["pw-public-subnet-az2-${var.env}"]
  }
}

data "aws_ecs_task_definition" "latest_task_definition" {
  task_definition = "${var.project_name}-pulse_Task_Definitions-${var.env}"  # Use the family name of your task definition
}

# Data sources for existing log groups
data "aws_cloudwatch_log_group" "pulse_logs" {
  name = "pw/ecs/pulse"
}

# resource "aws_cloudwatch_log_group" "ecs_logs" {
#   name              = data.aws_cloudwatch_log_group.pulse_logs
#   retention_in_days = 365
#   kms_key_id        = aws_kms_key.ecs.arn 
  

  

#   tags = merge(
#     var.tags,
#     {
#       Name = "pw-ecs-pulse"
#     }
#   )
# }





# CloudWatch Log Group for ECS
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "${var.project_name}/ecs/pulse-${var.env}"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.ecs.arn 
  

  

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-ecs-pulse-${var.env}"
    }
  )
}

######################################################################################################

resource "aws_kms_alias" "s3_encryption_key_alias" {
  name          = "alias/pw-ecs-pulse-${var.env}"
  target_key_id = aws_kms_key.ecs.key_id
}

resource "aws_kms_key" "ecs" {
  description             = "KMS key for ECS"
  deletion_window_in_days = 7
  enable_key_rotation     = true  # Enable automatic key rotation


  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowCloudWatchLogs"
        Effect = "Allow"
        Principal = {
          Service = "logs.${data.aws_region.current.name}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ]
        Resource = "*"
        Condition = {
          ArnEquals = {
            "kms:EncryptionContext:aws:logs:arn": [
              "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:pw/ecs/pulse",
              "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:pw/ecs/pulse-${var.env}",
              "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:aws-waf-logs-alb-${var.env}"
            ]
          }
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-ecs-kms-key-${var.env}"
    }
  )
}

  

######################################################################################################

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.project_name}-ecs-cluster-pulse-${var.env}"
  
  setting {
    name  = "containerInsights"
    value = "enhanced"
  }

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.ecs.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.ecs_logs.name
      }
    }
  }

  

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-ecs-cluster-pulse-${var.env}"
    }
  )
}


######################################################################################################

# resource "aws_ecs_task_definition" "pulse_task_definition" {
#   family                   = "${var.project_name}-pulse_Task_Definitions-${var.env}"
#   requires_compatibilities = ["FARGATE"]
#   network_mode             = "awsvpc"
#   execution_role_arn       = var.execution_role_arn
#   task_role_arn            = var.ecs_task_role_arn
#   cpu                      = "256"
#   memory                   = "512"

#   container_definitions = jsonencode([
#     {
#       name         = "pulse-container"
#       image        = "339713024244.dkr.ecr.us-east-1.amazonaws.com/prioritywaste/pulse:latest"
#       essential    = true
#       portMappings = [
#         {
#           containerPort = 4000
#           hostPort      = 4000
#         }
#       ]
#       logConfiguration = {
#         logDriver = "awslogs"
#         options   = {
#           awslogs-group         = "ecs/pulse"
#           awslogs-region        = "ap-southeast-1"
#           awslogs-stream-prefix = "pulse"
#           awslogs-create-group  = "true"
#         }
#       }
#       readonlyRootFilesystem = true  # Add this line to enable read-only root filesystem
#     }
#   ])

  

#   tags = merge(
#     var.tags,
#     {
#       Name = "${var.project_name}-pulse-task-definition-${var.env}"
#     }
#   )
# }


######################################################################################################

 resource "aws_cloudwatch_log_group" "ecs_pulse_log_groups" {
  name = "${var.project_name}/ecs/pulse"
  # You can optionally set retention in days (default is Never Expire)
  retention_in_days = 365  # Example: Retain logs for 7 days
  kms_key_id        = aws_kms_key.ecs.arn

  

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-ecs-logs"
    }
  )
 }

# ###################################################################################################

 resource "aws_ecs_service" "pulse_ecs_service" {
  name                = "${var.project_name}-pulse-service-${var.env}"
  cluster             = aws_ecs_cluster.ecs_cluster.id
  task_definition     = data.aws_ecs_task_definition.latest_task_definition.arn
  desired_count       = var.desired_count
  scheduling_strategy = "REPLICA"
  launch_type         = "FARGATE"

   # Health check grace period
  health_check_grace_period_seconds = 60

  # Deployment controller
  deployment_controller {
    type = "ECS"
  }

  # Tag management
  enable_ecs_managed_tags = true
  propagate_tags         = "SERVICE"

  # Enable ECS Exec
  enable_execute_command = true

 
  network_configuration {
    subnets          = [data.aws_subnet.private_subnet_az1.id, data.aws_subnet.private_subnet_az2.id]
    assign_public_ip = false
    security_groups  = var.ecs_security_group_ids
  }

  load_balancer {
    target_group_arn = var.pulse_target_group_arn
    container_name   = "pulse-container"
    container_port   = 4000
  }



  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-pulse-service-${var.env}"
    }
  )

   lifecycle {
    create_before_destroy = true
  }
}




# Application Auto Scaling Target
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = var.max_task_count
  min_capacity       = var.min_task_count
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.pulse_ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-ecs-autoscaling-target-${var.env}"
      ResourceType = "ECS Autoscaling Target"
    }
  )
}

# CPU Utilization Scaling Policy
resource "aws_appautoscaling_policy" "cpu_scaling" {
  name               = "${var.project_name}-cpu-scaling-${var.env}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.cpu_target_value
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
  
  
}

# Memory Utilization Scaling Policy
resource "aws_appautoscaling_policy" "memory_scaling" {
  name               = "${var.project_name}-memory-scaling-${var.env}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = var.memory_target_value
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}