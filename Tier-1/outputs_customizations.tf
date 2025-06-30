# outputs related to customizations

output "ecr_push_role_arn" {
  value = module.customizations.ecr_push_role_arn
}
output "eks_management_role_arn" {
  value = module.customizations.eks_management_role_arn
}
output "ssm_parameter_and_secret_read_only_role" {
  value = module.customizations.ssm_parameter_and_secret_read_only_role
}
output "secret_and_parameter_write_only_role" {
  value = module.customizations.secret_and_parameter_write_only_role
}
