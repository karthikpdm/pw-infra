aws_region           = "us-east-1"
assume_role_arn      = "arn:aws:iam::767397709508:role/pw-role-dev-crossaccount_infra_role"
env                  = "dev"
certificate_arn = "arn:aws:acm:us-east-1:767397709508:certificate/b6dca4cb-7e75-4ba8-8e2c-cec47b4f18e6"
eks_workers_sg_id    = "sg-0258a4a768946522e"
customer_domain = "customerprtlbe.dev.prioritywaste.com"
website_domain  = "websitebe.dev.prioritywaste.com"
internal_domain  = "internalbe.dev.prioritywaste.com"

#tags
map_tagging = {
  map-migrated  = "migSZUDBD3OY2"  
  track         = "devops"
  project       = "pw"
  env           = "dev"
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

account_id  = "767397709508"

################################################################################################
# Security Group Rules
################################################################################################


# # Security Group Rules
# master_ingress_rules = [
#   {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#     description = "Allow incoming HTTPS traffic from anywhere"
#   },
#   {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"  # -1 means all protocols
#     cidr_blocks = ["0.0.0.0/0"]
#     description = "Allow all incoming traffic"
#   }
# ]


# master_egress_rules = [
#   {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#     description = "Allow all outgoing traffic"
#   }
# ]

# workers_ingress_rules = [
#   {
#     from_port   = 1025
#     to_port     = 65535
#     protocol    = "tcp"
#     cidr_blocks = ["10.0.0.0/8"]
#     description = "Allow incoming traffic from VPC CIDR"
#   },
#   {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"  # -1 means all protocols
#     cidr_blocks = ["0.0.0.0/0"]
#     description = "Allow all incoming traffic"
#   }
# ]

# workers_egress_rules = [
#   {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#     description = "Allow all outgoing traffic"
#   }
# ]


# Security Group Rules
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
  "arn:aws:s3:::pwuploadbackend",
  "arn:aws:s3:::pwuploadbackend/*",
	"arn:aws:s3:::pw-s3-dev-upload-backend/*"
]

#kms list for EKS access
eks_kms_arns  = [
  "arn:aws:kms:us-east-1:767397709508:key/67464fce-218b-4a57-821a-7980473c05d2",
  "arn:aws:kms:us-east-1:767397709508:key/62ff6892-e705-4641-a793-67603c49361f",
	"arn:aws:kms:us-east-1:767397709508:key/56d3f6ef-3fb1-48a4-b1c3-39b8fd687404",
	"arn:aws:kms:us-east-1:767397709508:key/12c15b79-2c6e-402b-9402-684e47bdb647"
]


#secret manager for EKS access
eks_secret_manage_arns  = [
  "arn:aws:secretsmanager:us-east-1:767397709508:secret:pw-api-netsuite-credentials-secret-Wk0ZRh",
  "arn:aws:secretsmanager:us-east-1:767397709508:secret:/fleet/cognito/issuer-uri-XjdcsC",
  "arn:aws:secretsmanager:us-east-1:767397709508:secret:pw-scheduler-dispatcher-dev-secret-Nz5YKE"
]

#dynamodb list for EKS access
eks_dynamodb_arns  = [
  "arn:aws:dynamodb:us-east-1:767397709508:table/pw-portal-dev-Vehicle_Inspections",
  "arn:aws:dynamodb:us-east-1:767397709508:table/pw-portal-dev-Vehicle_Inspections/index/*",
  "arn:aws:dynamodb:us-east-1:767397709508:table/pw-portal-dev-jobs",
  "arn:aws:dynamodb:us-east-1:767397709508:table/pw-portal-dev-jobs/index/*",
  "arn:aws:dynamodb:us-east-1:767397709508:table/pw-portal-dev-Job_Details",
  "arn:aws:dynamodb:us-east-1:767397709508:table/pw-portal-dev-Job_Details/index/*",
  "arn:aws:dynamodb:us-east-1:767397709508:table/pw-portal-dev-routes",
  "arn:aws:dynamodb:us-east-1:767397709508:table/pw-portal-dev-routes/index/*",
  "arn:aws:dynamodb:us-east-1:767397709508:table/pw-portal-dev-rejection-key",
  "arn:aws:dynamodb:us-east-1:767397709508:table/pw-portal-dev-rejection-key/index/*",
  "arn:aws:dynamodb:us-east-1:767397709508:table/pw-portal-dev-disposal-operations",
  "arn:aws:dynamodb:us-east-1:767397709508:table/pw-portal-dev-disposal-sites",
  "arn:aws:dynamodb:us-east-1:767397709508:table/pw-portal-dev-waste-materials",
  "arn:aws:dynamodb:us-east-1:767397709508:table/holidays",
  "arn:aws:dynamodb:us-east-1:767397709508:table/deviceHealth",
  "arn:aws:dynamodb:us-east-1:767397709508:table/vehicle_telemetry_history",
  "arn:aws:dynamodb:us-east-1:767397709508:table/pw-portal-dev-route-leave-reasons",
  "arn:aws:dynamodb:us-east-1:767397709508:table/pw-portal-dev-notifications",
  "arn:aws:dynamodb:us-east-1:767397709508:table/pw-portal-dev-reject-job-reasons",
  "arn:aws:dynamodb:us-east-1:767397709508:table/pw-fleet-dev-vehicletelemetryhistory",
  "arn:aws:dynamodb:us-east-1:767397709508:table/pw-fleet-dev-livevehiclestatus",
  "arn:aws:dynamodb:us-east-1:767397709508:table/pw-fleet-dev-devicehealth",
  "arn:aws:dynamodb:us-east-1:767397709508:table/pw-fleet-dev-fleetml",
  "arn:aws:dynamodb:us-east-1:767397709508:table/pw-poc-job-websocket",
  "arn:aws:dynamodb:us-east-1:767397709508:table/pw-portal-dev-reject-job-history"
]

email_subscribers = ["ramya.amaravadhi@trianz.com","narayana.neelam@trianz.com"]

metrics_server_version  = "3.12.2"
fluent_bit_version      = "0.1.32"