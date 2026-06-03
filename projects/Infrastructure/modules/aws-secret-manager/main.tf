resource "aws_secretsmanager_secret" "this" {
  name                    = var.secret_name
  recovery_window_in_days = 7

  tags = {
    ManagedBy = "Terraform"
  }
}

resource "aws_secretsmanager_secret_version" "this" {

  secret_id = aws_secretsmanager_secret.this.id

  secret_string = jsonencode({
    username = var.username
    password = var.password
  })
}

resource "aws_iam_policy" "secret_access" {

  name = "${replace(var.secret_name, "/", "-")}-eso-policy"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]

        Resource = aws_secretsmanager_secret.this.arn
      }
    ]
  })
}

resource "aws_iam_role" "irsa_role" {

  name = "${replace(var.secret_name, "/", "-")}-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = var.oidc_provider_arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "${local.oidc_provider_host}:sub" = "system:serviceaccount:${var.namespace}:${var.service_account_name}"
          }
        }
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "attachment" {

  role       = aws_iam_role.irsa_role.name

  policy_arn = aws_iam_policy.secret_access.arn
}



# 1. Create Secret in AWS Secrets Manager
# 2. Store username/password inside the secret
# 3. Create IAM Policy to read the secret
# 4. Create IRSA Role and attach the policy