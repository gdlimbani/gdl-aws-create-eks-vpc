terraform {
  backend "s3" {
    bucket = "${var.bucket}"
    region = "${var.region}"
    key = "${var.key_eks_terraform_file_state}"
  }
}
