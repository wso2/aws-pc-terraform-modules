{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Sid": "AllowSSMParameterRead",
          "Effect": "Allow",
          "Action": [
              "ssm:GetParameter"
          ],
          "Resource": "${ssm_parameter_arn}"
      },
      {
          "Sid": "AllowEKSClusterDescribe",
          "Effect": "Allow",
          "Action": [
              "eks:DescribeCluster"
          ],
          "Resource": "*"
      }
  ]
}