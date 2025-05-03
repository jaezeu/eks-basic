output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = replace(module.eks.cluster_endpoint, "https://", "")
}