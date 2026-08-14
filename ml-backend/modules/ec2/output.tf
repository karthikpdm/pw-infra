
output "private_key_pem" {
  description = "The private key for SSH access to the EC2 instance"
  value       = tls_private_key.pwmy_key.private_key_pem
  sensitive   = true
}

output "public_key_openssh" {
  description = "The public key in OpenSSH format"
  value       = tls_private_key.pwmy_key.public_key_openssh
}

output "security_group_id" {
  description = "The ID of the security group created"
  value       = aws_security_group.pwmy_ec2_security_group.id
}

output "ec2_instance_id" {
  description = "The ID of the created EC2 instance"
  value       = aws_instance.pwmy_ec2_instance.id
}

output "ec2_instance_public_ip" {
  description = "The public IP address of the created EC2 instance"
  value       = aws_instance.pwmy_ec2_instance.public_ip
}

output "key_pair_name" {
  description = "The name of the key pair used for the EC2 instance"
  value       = aws_key_pair.pwmy_ec2_key_pair.key_name
}
