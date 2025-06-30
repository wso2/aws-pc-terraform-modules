locals {
  loadbalancer_controller_service_account_name = "wso2pc-sa-loadbalancer-controller-role"
  csi_secret_driver_service_account_name       = "wso2pc-sa-csi-secret-role"
  csi_ebs_driver_service_account_name          = "wso2pc-sa-csi-ebs-role"
  wso2_apim_service_account_name               = "wso2pc-sa-wso2am-apim"
}

##### IAM role for management VM, also grant access to eks cluster via EKS access entry
module "management_vm_iam_policy" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/IAM-Policy?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  application = "management-vm"
  policy      = file("${path.module}/resources/management-vm-iam-policy.json")
}

module "management_vm_role" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/IAM-Role?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  application = "management-vm"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  policy_arns = [
    module.management_vm_iam_policy.iam_policy_arn,
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

##### IAM role for EBS CSI role, allow access to eks cluster via OIDC
module "eks_node_group_role" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/IAM-Role?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  application = "eks-node"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
    }
  )
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ]
}

##### IAM role for Secret Manager CSI role, allow access to eks cluster via OIDC
module "rds_secret_access_policy" {
  count       = var.enable_tier_two ? 1 : 0
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/IAM-Policy?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  application = "rds-secret-access"
  policy = templatefile("${path.module}/resources/rds-secret-access-policy.json.tpl", {
    secret_arns = jsonencode([
      module.rds.db_root_secret_arn
    ])
  })
}

module "rds_secret_access_role" {
  count       = var.enable_tier_two ? 1 : 0
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/IAM-Role?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  application = "rds-secret-access"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "rds.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
  policy_arns = [module.rds_secret_access_policy[0].iam_policy_arn]
}

##### IAM role for Secret Manager CSI role, allow access to eks cluster via OIDC
module "csi_secret_iam_policy" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/IAM-Policy?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  application = "eks-csi-secret"
  policy      = file("${path.module}/resources/csi-secret-iam-policy.json")
}

module "csi_secret_role" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/IAM-Role?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  application = "eks-csi-secret"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Principal" : {
          "Federated" : "${module.eks.oidc_provider_arn}"
        },
        "Condition" : {
          "StringEquals" : {
            "${replace(module.eks.eks_cluster_issuer_url, "https://", "")}:aud" : "sts.amazonaws.com",
            "${replace(module.eks.eks_cluster_issuer_url, "https://", "")}:sub" : [
              "system:serviceaccount:database:${local.csi_secret_driver_service_account_name}",
              "system:serviceaccount:wso2-pc-application:${local.wso2_apim_service_account_name}"
            ]
          }
        }
      }
    ]
  })
  policy_arns = [module.csi_secret_iam_policy.iam_policy_arn]
}

##### IAM role for EBS CSI role, allow access to eks cluster via OIDC
module "csi_ebs_role" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/IAM-Role?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  application = "eks-csi-ebs"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Principal" : {
          "Federated" : "${module.eks.oidc_provider_arn}"
        },
        "Condition" : {
          "StringEquals" : {
            "${replace(module.eks.eks_cluster_issuer_url, "https://", "")}:aud" : "sts.amazonaws.com",
            "${replace(module.eks.eks_cluster_issuer_url, "https://", "")}:sub" : "system:serviceaccount:drivers:${local.csi_ebs_driver_service_account_name}"

          }
        }
      }
    ]
  })
  policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
}

#####  IAM Role used by AWS Loadbalance controller via OIDC.
module "lb_controller_iam_policy" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/IAM-Policy?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  application = "lb-controller"
  policy      = file("${path.module}/resources/aws-loadbalancer-controller-iam-policy.json")
  #   https://docs.aws.amazon.com/eks/latest/userguide/lbc-manifest.html#lbc-iam
}

module "lb_controller_role" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/IAM-Role?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  application = "eks-lb-controller"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Principal" : {
          "Federated" : "${module.eks.oidc_provider_arn}"
        },
        "Condition" : {
          "StringEquals" : {
            "${replace(module.eks.eks_cluster_issuer_url, "https://", "")}:aud" : "sts.amazonaws.com",
            "${replace(module.eks.eks_cluster_issuer_url, "https://", "")}:sub" : "system:serviceaccount:drivers:${local.loadbalancer_controller_service_account_name}"

          }
        }
      }
    ]
  })
  policy_arns = [module.lb_controller_iam_policy.iam_policy_arn]
}