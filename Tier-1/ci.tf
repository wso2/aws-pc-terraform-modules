module "docker_build" {
  count              = var.enable_cicd ? 1 : 0
  source             = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Code-Build?ref=UnitOfWork"
  description        = "CI project to build Docker image"
  project            = var.project
  build_name         = "docker"
  codebuild_role_arn = module.codebuild_role[0].iam_role_arn
  environment_variables = [
    {
      name  = "ECR_REGISTRY_URL"
      value = local.ecr_registry_url
    }
  ]
  tags = var.default_tags
}

module "buildspec_injector" {
  count              = var.enable_cicd ? 1 : 0
  source             = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Code-Build?ref=UnitOfWork"
  description        = "CI project to build Docker image"
  project            = var.project
  build_name         = "buildspec_injector"
  codebuild_role_arn = module.codebuild_role[0].iam_role_arn
  environment_variables = [
    {
      name  = "GITHUB_TOKEN"
      value = var.github_personal_access_token
    }
  ]
  codebuild_source = {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/resources/buildspec-injector.yml")
  }
  tags = var.default_tags
}

module "ci_s3_bucket" {
  count       = var.enable_cicd ? 1 : 0
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/S3-Account?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  application = var.ci_bucket_name
  tags        = var.default_tags
}

module "ci_pipeline" {
  count                = var.enable_cicd ? 1 : 0
  source               = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Code-Pipeline?ref=UnitOfWork"
  pipeline_name        = "ci"
  project              = var.project
  pipeline_role_arn    = module.codepipeline_role[0].iam_role_arn
  stages               = local.ci_stages
  artifact_bucket_name = join("-", [var.project, var.ci_bucket_name, var.environment, var.region, "bucket"])
  tags                 = var.default_tags
}
