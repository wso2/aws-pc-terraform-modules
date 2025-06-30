module "git_eks_access_entry" {
  source           = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/EKS-Access-Entry?ref=UnitOfWork"
  eks_cluster_name = var.eks_cluster_name
  principal_arn    = module.eks_management_role.iam_role_arn
}

module "git_eks_access_entry_policy" {
  source           = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/EKS-Access-Policy?ref=UnitOfWork"
  eks_cluster_name = var.eks_cluster_name
  principal_arn    = module.eks_management_role.iam_role_arn
  policy_arn       = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  type             = "cluster"
}