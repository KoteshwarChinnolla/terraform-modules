output "vpc_id" {
    value = module.vpc.vpc_id
    description = "The ID of the VPC"
}

output "public_subnet_ids" {
    value = module.vpc.public_subnet_ids
    description = "List of IDs of public subnets"
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "The endpoint of the EKS cluster"
}

output "cluster_name" {
  value       = module.eks.cluster_name
  description = "The name of the EKS cluster"
}