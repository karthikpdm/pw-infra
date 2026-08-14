#resource "aws_ecr_repository" "pwmy-ecr_repository" {
#  name                 = "${var.project_name}-${var.env}-ml-ecr-repository"
#  image_tag_mutability = "MUTABLE"

#  image_scanning_configuration {
#    scan_on_push = var.scan
#  }

#  tags = var.tags
#}

resource "aws_ecr_repository" "pwmy-ecr_repository" {
  name                 = "${var.project_name}-${var.env}-ml-ecr-repository"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = var.scan
  }

  tags = var.tags
}

# Add a lifecycle policy to manage images
resource "aws_ecr_lifecycle_policy" "pwmy_ecr_policy" {
  repository = aws_ecr_repository.pwmy-ecr_repository.name
  
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images older than 30 days"
        selection = {
          tagStatus    = "untagged"
          countType    = "sinceImagePushed"
          countUnit    = "days"
          countNumber  = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
