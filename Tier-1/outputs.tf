output "region" {
  value = var.region
}
output "vpc_id" {
  value = module.vpc.vpc_id
}
output "cluster_name" {
  value = module.eks.cluster_name
}
output "db_hostname" {
  value = var.enable_tier_two ? module.rds.db_proxy_endpoint : module.rds.db_instance_endpoint
}
output "rds_root_secret_arn" {
  value = module.rds.db_root_secret_arn
}
output "rds_root_secret_name" {
  value = module.rds.rds_root_secret_name
}
output "lb_controller_role_name" {
  value = module.lb_controller_role.iam_role_arn
}
output "csi_secret_role_name" {
  value = module.csi_secret_role.iam_role_arn
}
output "csi_ebs_role_name" {
  value = module.csi_ebs_role.iam_role_arn
}
output "public_security_group_id" {
  value = module.vpc.public_security_group_id
}
output "ecr_repository_name" {
  value = module.ecr.ecr_repository_url
}
output "ecr_push_role_arn" {
  value = module.ecr_push_role.iam_role_arn
}
output "eks_management_role_arn" {
  value = module.ecr.ecr_repository_url
}
output "ssm_parameter_and_secret_read_only_role" {
  value = module.ssm_parameter_and_secret_read_only_role.iam_role_arn
}
output "secret_and_parameter_write_only_role" {
  value = module.secret_and_parameter_write_only_role.iam_role_arn
}
