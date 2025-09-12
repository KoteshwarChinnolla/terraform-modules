resource_name = "hrms_eks_cluster"
vpc_cidr_block = "10.0.0.0/16"
private_subnet_cidr_blocks = ["10.0.1.0/24", "10.0.3.0/24"]
public_subnet_cidr_blocks = ["10.0.0.0/24", "10.0.2.0/24"]
availability_zones_private = ["ap-south-1a", "ap-south-1b"]
availability_zones_public = ["ap-south-1a", "ap-south-1b"]
master_iam_role_name = "hrms_eks_master_role"
worker_iam_role_name = "hrms_eks_worker_role"
kubernetes_version = "1.29"
node_group = {
  "hrms_node_group" = {
    instance_type = ["t3.medium"]
    capacity_type = "ON_DEMAND"
    desired_size  = 3
    max_size      = 4
    min_size      = 1
  }
}

# aws eks update-kubeconfig --region ap-south-1 --name hrms_eks_cluster