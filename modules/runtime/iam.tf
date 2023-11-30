/*resource "aws_iam_user" "iam_user" {
  name = "iam_user"
  path = "/system/"
}*/

resource "aws_iam_policy" "describe_ec2" {
  name = "describe_ec2"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
         "ec2:DescribeInstances", 
         "ec2:DescribeImages",
         "ec2:DescribeTags", 
         "ec2:DescribeSnapshots" 
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "describe_ec2" {
  name = "describe_ec2"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "describe_ec2" {
  role       = aws_iam_role.describe_ec2.name
  policy_arn = aws_iam_policy.describe_ec2.arn
}

resource "aws_iam_instance_profile" "describe_ec2" {
  name = "describe_ec2"
  role = aws_iam_role.describe_ec2.name
}

