{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Sid": "GetSecretValue",
          "Action": [
              "secretsmanager:GetSecretValue"
          ],
          "Effect": "Allow",
          "Resource": ${secret_arns}
      }
  ]
}