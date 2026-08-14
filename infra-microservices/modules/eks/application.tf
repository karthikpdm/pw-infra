resource "kubernetes_service_account" "customer" {
  automount_service_account_token = true
  metadata {
    name        = "customer"
    namespace   = var.customer_namespace_name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eks-customer-role.arn
    }
    labels = {
      "app.kubernetes.io/name"       = "eks-customer-role"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "aws_iam_role" "eks-customer-role" {
  name = "EksCustomerRole-${var.project_name}-eks-cluster-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect": "Allow"
        "Principal": {
          "Service": "eks.amazonaws.com"
        }
        "Action": "sts:AssumeRole",
        "Condition": {
          "StringEquals": {
            "aws:SourceAccount": "${var.account_id}"
          }
        }
      },
      {
        Effect = "Allow",
        Principal = {
          Federated = "${aws_iam_openid_connect_provider.eks.arn}"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:sub" : "system:serviceaccount:${var.customer_namespace_name}:customer",
            "${replace(aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
  
  tags = merge(
    { "Name"    = "EksCustomerRole-${var.project_name}-eks-cluster-${var.env}" },
    var.map_tagging
  )
}

resource "kubernetes_service_account" "website" {
  automount_service_account_token = true
  metadata {
    name        = "website"
    namespace   = var.website_namespace_name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eks-website-role.arn
    }
    labels = {
      "app.kubernetes.io/name"       = "eks-website-role"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "aws_iam_role" "eks-website-role" {
  name = "EksWebsiteRole-${var.project_name}-eks-cluster-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect": "Allow"
        "Principal": {
          "Service": "eks.amazonaws.com"
        }
        "Action": "sts:AssumeRole",
        "Condition": {
          "StringEquals": {
            "aws:SourceAccount": "${var.account_id}"
          }
        }
      },
      {
        Effect = "Allow",
        Principal = {
          Federated = "${aws_iam_openid_connect_provider.eks.arn}"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:sub" : "system:serviceaccount:${var.website_namespace_name}:website",
            "${replace(aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
  
  tags = merge(
    { "Name"    = "EksWebsiteRole-${var.project_name}-eks-cluster-${var.env}" },
    var.map_tagging
  )
}

resource "kubernetes_service_account" "internal" {
  automount_service_account_token = true
  metadata {
    name        = "internal"
    namespace   = var.internal_namespace_name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eks-internal-role.arn
    }
    labels = {
      "app.kubernetes.io/name"       = "eks-internal-role"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "aws_iam_role" "eks-internal-role" {
  name = "EksInternalRole-${var.project_name}-eks-cluster-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect": "Allow"
        "Principal": {
          "Service": "eks.amazonaws.com"
        }
        "Action": "sts:AssumeRole",
        "Condition": {
          "StringEquals": {
            "aws:SourceAccount": "${var.account_id}"
          }
        }
      },
      {
        Effect = "Allow",
        Principal = {
          Federated = "${aws_iam_openid_connect_provider.eks.arn}"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:sub" : "system:serviceaccount:${var.internal_namespace_name}:internal",
            "${replace(aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
  
  tags = merge(
    { "Name"    = "EksInternalRole-${var.project_name}-eks-cluster-${var.env}" },
    var.map_tagging
  )
}

resource "aws_iam_policy" "dynamodb-access-policy" {
  name = "${var.project_name}-eks-dynamodb-access-policy-${var.env}"
  description = "IAM policy for EKS to access DynamoDB"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ],
        Resource = "*"
      }
    ]
  })
  
  tags = merge(
    { "Name"    = "${var.project_name}-eks-dynamodb-access-policy-${var.env}" },
    var.map_tagging
  )
}

resource "aws_iam_role_policy_attachment" "aws-dynamodb-access" {
  role       = aws_iam_role.eks-internal-role.name
  policy_arn = aws_iam_policy.dynamodb-access-policy.arn
}