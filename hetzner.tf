resource "aws_iam_user" "iac-hetzner-dev" {
  name = "iac-hetzner-dev"
}

resource "aws_iam_access_key" "iac-hetzner-dev" {
  user = aws_iam_user.iac-hetzner-dev.name
}

resource "tfe_variable" "iac-hetzner-dev-aws-secret" {
  key          = "aws_secret"
  value        = aws_iam_access_key.iac-hetzner-dev.secret
  category     = "terraform"
  workspace_id = tfe_workspace.iac-hetzner-dev.id
}

resource "aws_iam_policy" "iac-hetzner-dev-secret" {
  name        = "iac-hetzner-dev"
  policy      = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "VisualEditor0",
              "Effect": "Allow",
              "Action": [
                  "secretsmanager:UntagResource",
                  "secretsmanager:GetSecretValue",
                  "secretsmanager:DescribeSecret",
                  "secretsmanager:PutSecretValue",
                  "secretsmanager:CreateSecret",
                  "secretsmanager:DeleteSecret",
                  "secretsmanager:ListSecretVersionIds",
                  "secretsmanager:TagResource",
                  "secretsmanager:UpdateSecret"
              ],
              "Resource": "arn:aws:secretsmanager:eu-central-1:${aws_caller_identity.current.account_id}:secret:iac-hetzner-dev"
          },
          {
              "Sid": "VisualEditor1",
              "Effect": "Allow",
              "Action": "secretsmanager:ListSecrets",
              "Resource": "*"
          }
      ]
  })
}

resource "aws_iam_user_policy_attachment" "iac-hetzner-dev-aws-secret" {
  user       = aws_iam_user.iac-hetzner-dev.name
  policy_arn = aws_iam_policy.iac-hetzner-dev-secret.arn
}

data "tfe_workspace" "iac-hetzner-dev" {
  name         = "iac-hetzner-dev"
  organization = tfe_organizations.cloud.names[0]
}

resource "tfe_variable" "iac-hetzner-dev-aws-key" {
  key          = "aws_key"
  value        = aws_iam_access_key.iac-hetzner-dev.id
  category     = "terraform"
  workspace_id = tfe_workspace.iac-hetzner-dev.id
}
