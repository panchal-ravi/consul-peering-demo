## Change to examples/applications directory
cd <repo_root>/examples/applications

## Deploy utils pod and label default ns
## Switch kubectl context to DC1 K8s cluster
k create ns utils --context $S1
k -n utils create deploy multitool --image=praqma/network-multitool --context $S1


## Service Registry Demo

### Deploy frontend
./scripts/sd/deploy-frontend.sh

### Resolve frontend
./scripts/sd/resolve.sh

### Deploy frontend-v2
./scripts/sd/deploy-frontend-v2.sh

### Resolve frontend
./scripts/sd/resolve.sh

### Deploy frontend-v2-failing
./scripts/sd/deploy-frontend-v2-failing.sh

### Resolve frontend
./scripts/sd/resolve.sh

### Reset 
./scripts/sd/reset.sh


---------------------------------------------------------------------------------------------------
## Security Demo

### Reset configurations
./scripts/reset.sh

### Deny access
./scripts/security/deny-access.sh

### Run Search
./scripts/run-search.sh

### Allow access
./scripts/security/allow-access.sh

### Run Search
./scripts/run-search.sh

---------------------------------------------------------------------------------------------------
## Failover Demo

### Reset configurations
./scripts/reset.sh

### Run Search
./scripts/run-search.sh

### Kill all instances of product service in local datacenter 
./scripts/failover/failover-no-local-instance.sh

### Run Search
./scripts/run-search.sh

---------------------------------------------------------------------------------------------------
## Traffic-Split Demo across sites/clusters

### Reset configurations
./scripts/reset.sh

### Run Search
./scripts/run-search.sh

### Apply traffic-split
./scripts/traffic-split/active-active.sh

### Run Search
./scripts/run-search.sh

### Kill all instances of product service in local datacenter 
./scripts/failover/failover-no-local-instance.sh

### Run Search
./scripts/run-search.sh

---------------------------------------------------------------------------------------------------
### Delete All
k get servicerouters.consul.hashicorp.com -oname --context $S2 | xargs -I{} kubectl delete {} --context $S1
k get servicesplitters.consul.hashicorp.com -oname --context $S2 | xargs -I{} kubectl delete {} --context $S1
k get serviceresolvers.consul.hashicorp.com -oname --context $S2 | xargs -I{} kubectl delete {} --context $S1
k get proxydefaults.consul.hashicorp.com -oname --context $S2 | xargs -I{} kubectl delete {} --context $S2
k get proxydefaults.consul.hashicorp.com -oname --context $S1 | xargs -I{} kubectl delete {} --context $S1
k get service -oname --context $S2 | grep -v kubernetes | xargs -I{} kubectl delete {} --context $S2
k get deploy -oname --context $S2 | xargs -I{} kubectl delete {} --context $S2
k get service -oname --context $S1 | grep -v kubernetes | xargs -I{} kubectl delete {} --context $S1
k get deploy -oname --context $S1 | xargs -I{} kubectl delete {} --context $S1

tfdt module.consul-dc2-server && tfdt module.consul-dc1-server && tfdt module.infra-aws

### Deploy initial services in dc1a and dc2
kubectl label ns default consul=enabled --context $S1
kubectl label ns default consul=enabled --context $S2
kubectl apply -f proxy-defaults.yml --context $S1
kubectl apply -f proxy-defaults.yml --context $S2
kubectl apply -f product/product-v1-dc2-default.yml --context $S2
kubectl apply -f product/export-service-product-dc2-to-dc1.yml --context $S2
kubectl apply -f product/service-intentions-dc2.yaml --context $S2
kubectl apply -f search/search.yml --context $S1
kubectl apply -f search/product-v1-local.yml --context $S1
kubectl apply -f search/ingress-gateway.yml --context $S1
kubectl apply -f search/service-intentions-product.yml --context $S1