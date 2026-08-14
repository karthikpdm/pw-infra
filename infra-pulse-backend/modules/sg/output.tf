output "ecs_pulse_sg_id" {
  description = "ID of the ECS Pulse Security Group"
  value       = aws_security_group.ecs_pulse.id
}

output "alb_pulse_sg_id" {
  description = "ID of the ALB Pulse Security Group"
  value       = aws_security_group.alb-pulse.id
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = data.aws_vpc.pw_vpc.id
}
