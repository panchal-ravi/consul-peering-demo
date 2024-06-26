output "vpc_public_subnet_id" {
  value = module.vpc.public_subnets
}

output "sg_ssh_id" {
  value = module.sg-ssh.security_group_id
}

output "sg_consul_id" {
  value = module.sg-consul.security_group_id
}

output "eks_cluster_ids" {
  value = { for k, v in module.eks : k => v.cluster_id }
}

output "eks_cluster_api_endpoints" {
  value = { for k, v in module.eks : k => v.cluster_endpoint }
}

output "cluster_oidc_issuer_url" {
  value = { for k, v in module.eks: k => v.cluster_oidc_issuer_url}
}
