data "aws_iam_policy_document" "admin_policy" {
  statement {
    sid    = "Push only policy"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [module.ecr_push_role.iam_role_arn]
    }

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
  }
  statement {
    sid    = "Pull only policy"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [var.eks_node_group_role_iam_role_arn]
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability"
    ]
  }
}

resource "aws_ecr_repository_policy" "ecr_policy" {
  repository = var.ecr_name
  policy     = data.aws_iam_policy_document.admin_policy.json
}