output "eks_master_sg_id" {
  value = aws_security_group.eks_master_sg.id
}

output "eks_alb_ingress_websocket_sg_id" {
  value = aws_security_group.internal_websocket_alb_sg.id
}

output "eks_alb_ingress_sg_id" {
  value = aws_security_group.alb-ingress_sg.id
}