resource "aws_iam_user" "iac-hetzner-dev-pipeline-user" {
  name = "iac-hetzner-dev"
}

resource "aws_iam_access_key" "iac-hetzner-dev-pipeline-creds" {
  #ts:skip=AC_AWS_0133 Creds are made sensitive and only added to workspaces secrets
  user = aws_iam_user.iac-hetzner-dev-pipeline-user.name
}

resource "aws_iam_user_policy" "iac-hetzner-dev-iam-assume-policy" {
  #ts:skip=AC_AWS_0475 Only allow user to assume role
  name = "iac-hetzner-dev-secret-role_assume"
  user = aws_iam_user.iac-hetzner-dev-pipeline-user.name
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "RoleIaCHetznerDevSecret",
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.iac-hetzner-dev-role.name}"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "iac-hetzner-dev-role-policies" {
  name        = "iac-hetzner-dev"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetRandomPassword",
                "secretsmanager:ListSecrets"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "secretsmanager:*",
            "Resource": "arn:aws:secretsmanager:eu-central-1:${data.aws_caller_identity.current.account_id}:secret:${aws_secretsmanager_secret.iac-hetzner-dev.name}"
        }
    ]
  })
}

resource "aws_iam_role" "iac-hetzner-dev-role" {
  name = "iac-hetzner-dev-secret"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal: {
            AWS: "570931902845"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "iac-hetzner-dev-policy-role-attach" {
  role       = aws_iam_role.iac-hetzner-dev-role.name
  policy_arn = aws_iam_policy.iac-hetzner-dev-role-policies.arn
}


data "tfe_workspace" "iac-hetzner-dev" {
  name         = "iac-hetzner-dev"
  organization = data.tfe_organizations.cloud.names[0]
}

resource "tfe_variable" "iac-hetzner-dev-aws-key" {
  key          = "aws_key"
  sensitive    = true
  value        = resource.aws_iam_access_key.iac-hetzner-dev-pipeline-creds.id
  category     = "terraform"
  workspace_id = data.tfe_workspace.iac-hetzner-dev.id
}

resource "tfe_variable" "iac-hetzner-dev-aws-secret" {
  key          = "aws_secret"
  sensitive    = true
  value        = resource.aws_iam_access_key.iac-hetzner-dev-pipeline-creds.secret
  category     = "terraform"
  workspace_id = data.tfe_workspace.iac-hetzner-dev.id
}

resource "tfe_variable" "iac-hetzner-dev-aws-role" {
  key          = "aws_role"
  sensitive    = true
  value        = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.iac-hetzner-dev-role.name}"
  category     = "terraform"
  workspace_id = data.tfe_workspace.iac-hetzner-dev.id
}

resource "aws_secretsmanager_secret" "iac-hetzner-dev" {
  #ts:skip=AC_AWS_0500 No need for test-creds to be encrypted
  name = "iac-hetzner-dev-config"
}
