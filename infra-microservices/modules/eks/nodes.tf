# EKS Node Group Resource
resource "aws_eks_node_group" "node-grp" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.project_name}-eks-node-group-${var.env}-${formatdate("DD-MM-YYYY-hh-mm", timestamp())}"
  node_role_arn   = var.worker_role_arn
  subnet_ids      = [data.aws_subnet.private_subnet_az1.id, data.aws_subnet.private_subnet_az2.id]

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable = var.max_unavailable
  }
  
  ami_type              = "CUSTOM"
  force_update_version  = true
  
  launch_template {
    version = aws_launch_template.eks-node.latest_version
    name    = aws_launch_template.eks-node.name
  }

  tags = merge(
    { "Name"    = "${var.project_name}-node-group-${var.env}" },
    { "karpenter.sh/discovery/${aws_eks_cluster.eks.name}" = aws_eks_cluster.eks.name },
    { "karpenter.k8s.aws/cluster"                          = var.env }, 
    var.map_tagging
  )
  
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [node_group_name]
  }
}

data "aws_ami" "eks-worker-ami" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.eks_version}-*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon Account ID
}

resource "aws_launch_template" "eks-node" {
  name = "${var.project_name}-eks-nodes-${var.env}"

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "disabled"
  }

  network_interfaces {
    associate_public_ip_address = false
    #security_groups             = [var.eks_worker_sg_id]
  }

  monitoring {
    enabled = true
  }

  image_id      = data.aws_ami.eks-worker-ami.id
  instance_type = var.instance_type

  user_data = base64encode(local.node-userdata)
  
  block_device_mappings {
    device_name = "/dev/xvda" # Default root volume device name for Amazon Linux and Ubuntu
    ebs {
      delete_on_termination = true
      encrypted             = true
      volume_size           = var.disk_size             # Root volume size in GiB
      volume_type           = "gp3"          # General Purpose SSD
    }
  }

  tags = {
    Name                                                 = "${var.project_name}-eks-nodes-${var.env}"
    "karpenter.k8s.aws/cluster"                          = var.env
    "karpenter.sh/discovery/${aws_eks_cluster.eks.name}" = aws_eks_cluster.eks.name
    "kubernetes.io/cluster/clusterName"                  = "owned"
  }
  
  tag_specifications {
    resource_type = "instance"
    
    tags = merge(
    { "Name"    = "${var.project_name}-eks-node-${var.env}" },
    var.map_tagging
    )
  }
  
  tag_specifications {
    resource_type = "volume"
    
    tags = merge(
    { "Name"    = "${var.project_name}-eks-node-volume-${var.env}" },
    var.map_tagging
    )
  }
}

data "aws_autoscaling_groups" "eks_asg" {
  filter {
    name   = "tag:eks:nodegroup-name"
    values = [aws_eks_node_group.node-grp.node_group_name]
  }
}

resource "aws_autoscaling_group_tag" "eks_asg_extra_tags" {

  for_each = var.map_tagging
  
  autoscaling_group_name = tolist(data.aws_autoscaling_groups.eks_asg.names)[0]
  
  tag {
    key                 = each.key
    value               = each.value
    propagate_at_launch = true
  }
}