# iam

module "iam" {
  source = "./modules/iam"

  project_name                  = var.project_name
  env                           = var.env
  tags = var.tags
  
}
# Reference ECS module
module "ecs" {
  source = "./modules/ecs"

  project_name                  = var.project_name
  env                           = var.env
  aws_region                    = var.aws_region
  execution_role_arn            = module.iam.ecs_task_execution_role_arn
  ecs_task_role_arn             = module.iam.ecs_task_role_arn
  ecs_security_group_ids        = [module.sg.ecs_pulse_sg_id,module.sg.ecs_pulse_sg_id]
  pulse_target_group_arn        = module.alb.target_group_arn
  tags = var.tags
  desired_count                 = var.desired_count
  max_task_count                = var.max_task_count
  min_task_count                = var.min_task_count
  cpu_target_value              = var.cpu_target_value
  memory_target_value           = var.memory_target_value
}

# Reference ALB module
module "alb" {

  source = "./modules/alb"

  project_name           = var.project_name
  env                    = var.env
  alb_security_group     = module.sg.alb_pulse_sg_id
  # target_group_arn       = aws_lb_target_group.pulse.arn
  certificate_arn        = var.certificate_arn
  tags = var.tags
}

# Module for Security Groups
module "sg" {
  source = "./modules/sg"

  project_name                = var.project_name
  env                         = var.env
  ecs_pulse_ingress_rules     = var.ecs_pulse_ingress_rules
  ecs_pulse_egress_rules      = var.ecs_pulse_egress_rules
  # alb_pulse_ingress_rules     = var.alb_pulse_ingress_rules
  alb_pulse_egress_rules      = var.alb_pulse_egress_rules
  tags = var.tags
}

module "waf" {
  source = "./modules/waf"

  env           = var.env
  project_name  = var.project_name
  tags          = var.tags
  alb_arn       = module.alb.alb_arn  # Assuming you have an output for ALB ARN in the ALB module
  kms_key_id    = module.ecs.kms_key_arn 

}



