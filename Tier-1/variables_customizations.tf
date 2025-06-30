# variables related to customizations

variable "k8s_repo" {
  type        = string
  description = "Git repo name storing APIM application K8/HELM artifacts (org/repo)"
}
variable "git_oidc_provider_arn" {
  type        = string
  description = "Arn of the github oidc provider."
}