output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.pulse.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.pulse.dns_name
}

# output "listener_arn" {
#   description = "ARN of the ALB Listener"
#   value       = aws_lb_listener.listener_http.arn
# }

# output "listener_arn" {
#   description = "ARN of the ALB Listener"
#   value       = aws_lb_listener.listener_http.arn
# }

output "target_group_arn" {
  description = "ARN of the ALB Target Group"
  value       = aws_lb_target_group.pulse.arn
}

# output "listener_rule_arn" {
#   description = "ARN of the ALB Listener Rule"
#   value       = aws_lb_listener_rule.pulse_rule.arn
# }

# In ALB module outputs.tf
# output "alb_arn" {
#   description = "ARN of the Application Load Balancer"
#   value       = aws_lb.pulse.arn
# }