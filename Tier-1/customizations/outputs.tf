# outputs related to customizations

output "ecr_push_role_arn" {
  value = module.ecr_push_role.iam_role_arn
}
output "eks_management_role_arn" {
  value = module.eks_management_role.iam_role_arn
}
output "ssm_parameter_and_secret_read_only_role" {
  value = module.ssm_parameter_and_secret_read_only_role.iam_role_arn
}
output "secret_and_parameter_write_only_role" {
  value = module.secret_and_parameter_write_only_role.iam_role_arn
}
