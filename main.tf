locals {
  deployment_id             = lower("${var.deployment_name}-${random_string.suffix.result}")
  key_name                  = "ssh_key"
  local_privatekey_path     = "${path.root}/generated"
  local_privatekey_filename = "ssh-key"
  consul_datacenters        = ["dc1", "dc2"]
  eks_clusters = {
    "dc1-server"  = {}
    "dc2-server"  = {}
  }
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "aws_key_pair" "this" {
  key_name   = "${local.deployment_id}-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.ssh.private_key_openssh
  filename = "${path.root}/generated/${local.key_name}"

  provisioner "local-exec" {
    command = "chmod 400 ${path.root}/generated/${local.key_name}"
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "infra-aws" {
  source = "./modules/infra/aws"

  region                             = var.aws_region
  owner                              = var.owner
  ttl                                = var.ttl
  deployment_id                      = local.deployment_id
  key_pair_key_name                  = aws_key_pair.this.key_name //var.aws_key_pair_key_name
  vpc_cidr                           = var.aws_vpc_cidr
  public_subnets                     = var.aws_public_subnets
  private_subnets                    = var.aws_private_subnets
  cluster_version                    = var.aws_eks_cluster_version
  cluster_service_cidr               = var.aws_eks_cluster_service_cidr
  self_managed_node_instance_type    = var.aws_eks_self_managed_node_instance_type
  self_managed_node_desired_capacity = var.aws_eks_self_managed_node_desired_capacity
  eks_clusters                       = local.eks_clusters
  local_privatekey_path              = local.local_privatekey_path
  local_privatekey_filename          = local.local_privatekey_filename
  consul_serf_lan_port               = var.consul_serf_lan_port
  ent_license                        = var.consul_ent_license
  instance_type                      = var.aws_instance_type
}

module "consul-dc1-server" {
  source = "./modules/consul/consul-server"
  providers = {
    kubernetes = kubernetes.dc1-server,
    helm       = helm.dc1-server
  }

  deployment_name    = var.deployment_name
  datacenter         = local.consul_datacenters[0]
  helm_chart_version = var.consul_helm_chart_version
  consul_version     = var.consul_version
  # consul_k8s_version = var.consul_k8s_version
  ent_license        = var.consul_ent_license
  replicas           = var.consul_replicas
  serf_lan_port      = var.consul_serf_lan_port
  /* eks_cluster_suffix = "dc1-server" */

  depends_on = [
    module.infra-aws
  ]
}

module "consul-dc2-server" {
  source = "./modules/consul/consul-server"
  providers = {
    kubernetes = kubernetes.dc2-server,
    helm       = helm.dc2-server
  }

  deployment_name    = var.deployment_name
  datacenter         = local.consul_datacenters[1]
  helm_chart_version = var.consul_helm_chart_version
  consul_version     = var.consul_version
  ent_license        = var.consul_ent_license
  replicas           = var.consul_replicas
  serf_lan_port      = var.consul_serf_lan_port

  depends_on = [
    module.infra-aws
  ]
}
