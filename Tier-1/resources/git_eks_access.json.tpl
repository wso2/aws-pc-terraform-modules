{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Sid": "Allow to access SSM parameter",
          "Effect": "Allow",
          "Action": [
              "ssm:GetParameter"
          ],
          "Resource": "${ssm_parameter_arn}"
      },
      {
          "Sid": "Allow to describe EKS cluster",
          "Effect": "Allow",
          "Action": [
              "eks:DescribeCluster"
          ],
          "Resource": "${eks_cluster_arn}"
      }
  ]
}