# Define the IAM Policy
resource "aws_iam_policy" "eks_policy" {
  name        = "${var.policy_name}"
  description = "EKS Policy for creating node groups and related permissions"
  policy      = jsonencode({
    Version = "2012-10-17"
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "kms:CreateKey",
          "kms:DescribeKey",
          "kms:ListKeys",
          "kms:TagResource",
          "kms:CreateAlias",
          "kms:DeleteAlias",
          "kms:ListAliases",
          "kms:PutKeyPolicy"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:TagResource",
          "logs:DescribeLogGroups",
          "logs:ListTagsForResource",
          "logs:PutLogEvents",
          "logs:DeleteLogGroup",
          "logs:CreateLogStream",
          "logs:PutRetentionPolicy"
        ],
        "Resource": "*"
      }
	  ]
  })
  tags = {
    Environment = "development"
    Application = "eks-cluster"
    CreatedBy  = "${var.resource_created_by}"
    PolicyAttachment = "eks-policy-attachment"
  }
}

# Fetch the IAM user to whom the policy will be attached
resource "aws_iam_user" "eks_user" {
  count = length(data.aws_iam_user.existing_user.id) == 0 ? 1 : 0
  name = "${var.user_name}"
}

# Attach the policy to the IAM user
resource "aws_iam_policy_attachment" "eks_policy_attachment" {
  count = length(data.aws_iam_user.existing_user.id) > 0 || length(aws_iam_user.eks_user) > 0 ? 1 : 0
  name       = "${var.env_prefix}-eks-policy-attachment"
  users      = [length(data.aws_iam_user.existing_user.id) > 0 ? data.aws_iam_user.existing_user.user_name : aws_iam_user.eks_user[0].name]
  policy_arn = aws_iam_policy.eks_policy.arn
}