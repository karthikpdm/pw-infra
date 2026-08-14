resource "aws_cognito_identity_pool" "main" {
  identity_pool_name               = var.identity_pool_name
  allow_unauthenticated_identities = false

  tags = var.tags
}

resource "aws_cognito_identity_pool_roles_attachment" "main" {
  identity_pool_id = aws_cognito_identity_pool.main.id

  roles = {
    "authenticated" = var.identity_pool_role_name_arn
  }
}

resource "aws_cognito_identity_pool" "telemetry_pool" {
  identity_pool_name               = "tf-pw-telemetry-pool"
  allow_unauthenticated_identities = true
  allow_classic_flow               = true

  # cognito_identity_providers {
  #   client_id                = aws_cognito_user_pool_client.telemetry_pool.id
  #   provider_name           = aws_cognito_user_pool.telemetry_pool_user.endpoint
  #   server_side_token_check = true
  # }
}

# resource "aws_cognito_user_pool" "telemetry_pool_user" {
#   name = "tf-pw-user-pool"
# }

# resource "aws_cognito_user_pool_client" "telemetry_pool" {
#   name         = "tf-pw-user-pool-client"
#   user_pool_id = aws_cognito_user_pool.telemetry_pool_user.id

#   allowed_oauth_flows_user_pool_client = true
#   explicit_auth_flows                  = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
# }

resource "aws_iam_role" "unauthenticated" {
  name = "pw_unauthenticated_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          "StringEquals" = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.telemetry_pool.id
          },
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "unauthenticated"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "authenticated" {
  name = "pw_authenticated_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          "StringEquals" = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.telemetry_pool.id
          },
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "authenticated"
          }
        }
      }
    ]
  })
}

resource "aws_cognito_identity_pool_roles_attachment" "telemetry_pool_user" {
  identity_pool_id = aws_cognito_identity_pool.telemetry_pool.id

  roles = {
    "unauthenticated" = aws_iam_role.unauthenticated.arn
    "authenticated"   = aws_iam_role.authenticated.arn
  }
}
