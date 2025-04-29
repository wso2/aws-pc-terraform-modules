data "aws_caller_identity" "current" {}
data "aws_default_tags" "defaultTags" {}
data "aws_region" "current" {}
data "aws_availability_zones" "availability_zones" {
  state = "available"
}