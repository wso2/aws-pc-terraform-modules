# variables related to customizations

variable "project" {
  type        = string
  description = "Project"
}
variable "environment" {
  type        = string
  description = "Environment"
}
variable "region" {
  type        = string
  description = "Region"
}
variable "application" {
  type        = string
  description = "Application"
}
variable "default_tags" {
  type        = map(string)
  description = "Map of default tags to apply to all resources deployed during Private Cloud deployment."
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}
variable "eks_node_group_role_iam_role_arn" {
  description = "EKS node group role arns"
  type        = string
}
variable "ecr_name" {
  description = "ECR name"
  type        = string
}
variable "k8s_repo" {
  type        = string
  description = "Git repo name storing APIM application K8/HELM artifacts (org/repo)"
}
variable "git_oidc_provider_arn" {
  type        = string
  description = "Arn of the github oidc provider."
}