terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.20.0"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.35.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.12.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_eks_cluster" "dc1-server" {
  name = module.infra-aws.eks_cluster_ids["dc1-server"]
}

data "aws_eks_cluster_auth" "dc1-server" {
  name = module.infra-aws.eks_cluster_ids["dc1-server"]
}

data "aws_eks_cluster" "dc2-server" {
  name = module.infra-aws.eks_cluster_ids["dc2-server"]
}

data "aws_eks_cluster_auth" "dc2-server" {
  name = module.infra-aws.eks_cluster_ids["dc2-server"]
}


provider "kubernetes" {
  alias                  = "dc1-server"
  host                   = data.aws_eks_cluster.dc1-server.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.dc1-server.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.dc1-server.token
}

provider "helm" {
  alias = "dc1-server"
  kubernetes {
    host                   = data.aws_eks_cluster.dc1-server.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.dc1-server.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.dc1-server.token
  }
}

provider "kubernetes" {
  alias                  = "dc2-server"
  host                   = data.aws_eks_cluster.dc2-server.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.dc2-server.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.dc2-server.token
}

provider "helm" {
  alias = "dc2-server"
  kubernetes {
    host                   = data.aws_eks_cluster.dc2-server.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.dc2-server.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.dc2-server.token
  }
}

provider "consul" {
  alias          = "dc1-server"
  address        = module.consul-dc1-server.ui_public_fqdn
  scheme         = "https"
  datacenter     = local.consul_datacenters[0]
  token          = module.consul-dc1-server.consul-bootstrap-acl-token.token
  insecure_https = true
}

provider "consul" {
  alias          = "dc2-server"
  address        = module.consul-dc2-server.ui_public_fqdn
  scheme         = "https"
  datacenter     = local.consul_datacenters[1]
  token          = module.consul-dc2-server.consul-bootstrap-acl-token.token
  insecure_https = true
}
