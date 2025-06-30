#### IAM assume role for GitHub action for EKS cluster management, used by EKS access entry
module "eks_management_iam_policy" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/IAM-Policy?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  application = "eks_management"
  policy = templatefile("${path.module}/resources/git_eks_access.json.tpl", {
    ssm_parameter_arn = "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/pc_deployment_parameters"
  })
}

module "eks_management_role" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/IAM-Role?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  application = "eks_management"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Federated" : "${var.git_oidc_provider_arn}"
          },
          "Action" : "sts:AssumeRoleWithWebIdentity",
          "Condition" : {
            "StringEquals" : {
              "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
            },
            "StringLike" : {
              "token.actions.githubusercontent.com:sub" : "repo:${var.k8s_repo}:*"
            }
          }
        }
      ]
    }
  )
  policy_arns = [module.eks_management_iam_policy.iam_policy_arn]
}

#### IAM assume role for GitHub action for ECR Image publish
module "ecr_push_only_iam_policy" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/IAM-Policy?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  application = "ecr_push_only"
  policy      = file("${path.module}/resources/ecr_push_only_policy.json")
}

module "ecr_push_role" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/IAM-Role?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  application = "ecr_image_push"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Federated" : "${var.git_oidc_provider_arn}"
          },
          "Action" : "sts:AssumeRoleWithWebIdentity",
          "Condition" : {
            "StringEquals" : {
              "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
            },
            "StringLike" : {
              "token.actions.githubusercontent.com:sub" : "repo:${var.k8s_repo}:*"
            }
          }
        }
      ]
    }
  )
  policy_arns = [module.ecr_push_only_iam_policy.iam_policy_arn]
}

#### IAM assume role for GitHub action for SSM Parameter Store get parameter
module "ssm_parameter_and_secret_read_only_iam_policy" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/IAM-Policy?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  application = "ssm_parameter_and_secret_read_only"
  policy      = file("${path.module}/resources/ssm_parameter_and_secret_read_only_policy.json")
}

module "ssm_parameter_and_secret_read_only_role" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/IAM-Role?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  application = "parameter_read_only"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Federated" : "${var.git_oidc_provider_arn}"
          },
          "Action" : "sts:AssumeRoleWithWebIdentity",
          "Condition" : {
            "StringEquals" : {
              "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
            },
            "StringLike" : {
              "token.actions.githubusercontent.com:sub" : "repo:${var.k8s_repo}:*"
            }
          }
        }
      ]
    }
  )
  policy_arns = [module.ssm_parameter_and_secret_read_only_iam_policy.iam_policy_arn]
}

#### IAM assume role for GitHub action for SecretStore Writes
module "secret_and_parameter_write_only_iam_policy" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/IAM-Policy?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  application = "secret_and_parameter_write_only"
  policy      = file("${path.module}/resources/ssm_parameter_and_secret_write_only_policy.json")
}

module "secret_and_parameter_write_only_role" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/IAM-Role?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  application = "secret_and_parameter_write_only"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Federated" : "${var.git_oidc_provider_arn}"
          },
          "Action" : "sts:AssumeRoleWithWebIdentity",
          "Condition" : {
            "StringEquals" : {
              "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
            },
            "StringLike" : {
              "token.actions.githubusercontent.com:sub" : "repo:${var.k8s_repo}:*"
            }
          }
        }
      ]
    }
  )
  policy_arns = [module.secret_and_parameter_write_only_iam_policy.iam_policy_arn]
}