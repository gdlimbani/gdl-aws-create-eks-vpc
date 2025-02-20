module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "~> 20.33.1"
    cluster_name = "${var.cluster_name}"
    cluster_version = "${var.cluster_version}"

    cluster_endpoint_public_access  = true

    vpc_id = module.my-vpc.vpc_id
    subnet_ids = module.my-vpc.private_subnets

    tags = {
        Environment = "development"
        Application = "nginx-app"
        CreatedBy = "${var.resource_created_by}"
    }

    eks_managed_node_groups = {
        dev = {
            min_size = 1
            max_size = 3
            desired_size = 2

            instance_types = ["t2.small"]

            # Use the default Amazon EKS optimized AMI for AL2 (Amazon Linux 2)
            ami_type = "AL2_x86_64"  # Use the AL2 Amazon Linux 2 AMI (this is for EKS version 1.24)
        }
    }
}
