aws_region           = "us-east-1"
assume_role_arn      = "arn:aws:iam::891377117055:role/pw-role-uat-crossaccount_infra_role"
env                  = "uat"
certificate_arn = "arn:aws:acm:us-east-1:891377117055:certificate/c69f0a7d-436c-4d77-b783-e19f47079a9e"
customer_domain = "customerprtlbe.uat.prioritywaste.com"
website_domain  = "websitebe.uat.prioritywaste.com"
internal_domain = "internalbe.uat.prioritywaste.com"

#tags
map_tagging = {
  map-migrated  = "migSZUDBD3OY2"  
  track         = "devops"
  project       = "pw"
  env           = "uat"
}

# EKS settings
eks_version      = "1.32"  # Replace with your desired EKS version
desired_size     = 2
max_size         = 3
min_size         = 2
instance_type    = "t2.medium"
disk_size        = 20
max_unavailable  = 1
ami_type         = "AL2"

karpenter_version = "1.0.6"
karpenter_vcpu    = "10"
karpenter_memory  = "100"

account_id = "891377117055"

################################################################################################
# Security Group Rules
################################################################################################
master_ingress_rules = [
  {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming HTTPS traffic from anywhere"
  }
]

master_egress_rules = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outgoing traffic"
  }
]

workers_ingress_rules = [
  {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS incoming traffic from anywhere"
  },
  {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"  
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP incoming traffic from anywhere"
  }
]

workers_egress_rules = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outgoing traffic"
  }
]

#s3 bucket list for EKS access
eks_s3_bucket_arns = [
	"arn:aws:s3:::pw-s3-uat-upload-backend/*"
]

#kms list for EKS access
eks_kms_arns  = [
  "arn:aws:kms:us-east-1:891377117055:key/77a7c705-d9f7-43bf-8c01-610ffc424e04",
  "arn:aws:kms:us-east-1:891377117055:key/be78887c-5184-4a45-8dbf-c3f56e6f17f3"
]


#secret manager for EKS access
eks_secret_manage_arns  = [
  "arn:aws:secretsmanager:us-east-1:891377117055:pw-api-netsuite-credentials-secret*"
]

#dynamodb list for EKS access
eks_dynamodb_arns  = [
  "arn:aws:dynamodb:us-east-1:891377117055:table/pw-fleet-uat-vehicletelemetryhistory",
  "arn:aws:dynamodb:us-east-1:891377117055:table/pw-fleet-uat-livevehiclestatus",
  "arn:aws:dynamodb:us-east-1:891377117055:table/pw-fleet-uat-devicehealth",
  "arn:aws:dynamodb:us-east-1:891377117055:table/pw-fleet-uat-fleetml",
]

email_subscribers = ["ramya.amaravadhi@trianz.com","narayana.neelam@trianz.com"]

metrics_server_version  = "3.12.2"
fluent_bit_version      = "0.1.32"