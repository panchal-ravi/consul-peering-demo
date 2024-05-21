### Export Consul enterprise license as terraform variable
```sh
export TF_VAR_consul_ent_license = <COPY_LICENSE_HERE>
```

### Set below variables in terraform.tfvars
```sh
aws_region                              = "ap-southeast-1"
owner                                   = "rp"
aws_key_pair_key_name                   = "ssh-key"
deployment_name                         = "rp-cpeer"
consul_version                          = "1.18.2-ent"
consul_helm_chart_version               = "1.4.1"
aws_eks_self_managed_node_instance_type = "t3.medium"
aws_eks_cluster_version                 = "1.28"
```

### Apply terraform modules
```sh
terraform apply -auto-approve -target module.infra-aws 
terraform apply -auto-approve -target module.consul-dc1-server
terraform apply -auto-approve -target module.consul-dc2-server
```

### Setup cluster peering
Follow the steps listed in `./cluster-peering-yamls-defaults/peering.md`

### Test scenarios
Follow the steps listed in `./examples/applications/steps.md`