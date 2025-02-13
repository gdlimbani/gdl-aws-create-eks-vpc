module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "~> 19.0"
    cluster_name = "my-eks-cluster"
    cluster_version = "1.24"

    cluster_endpoint_public_access  = true

    vpc_id = module.my-vpc.vpc_id
    subnet_ids = module.my-vpc.private_subnets

    tags = {
        Environment = "development"
        Application = "nginx-app"
        CreatedBy = "Gautam Limbani"
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
