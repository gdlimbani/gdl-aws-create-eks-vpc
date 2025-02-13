# Fetch the current AWS account ID
data "aws_iam_user" "existing_user" {
  user_name = "gautam.limbani"
}