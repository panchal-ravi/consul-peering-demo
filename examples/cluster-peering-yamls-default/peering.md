## Configure cluster peering
```sh
export S1=$(kubectl config get-contexts -oname | grep -i "dc1-server")
export S2=$(kubectl config get-contexts -oname | grep -i dc2-server)
```

Apply ```peer-through-meshgateways.yaml``` to configure control-plane traffic routing via mesh gateway. 
This should be applied in the default partition of all Consul Datacenters you want to peer where Consul servers are running.
```sh
kubectl apply -f examples/cluster-peering-yamls-default/peer-through-meshgateways.yaml --context $S1
kubectl apply -f examples/cluster-peering-yamls-default/peer-through-meshgateways.yaml --context $S2
```

Apply ```proxy-defaults.yaml``` file to all default partitions for HTTP services. 
This is to route traffic from local services to remote services via mesh gateways.
```sh
kubectl apply -f examples/cluster-peering-yamls-default/proxy-defaults.yaml --context $S1
kubectl apply -f examples/cluster-peering-yamls-default/proxy-defaults.yaml --context $S2
```

## Setup cluster peering between dc1 and dc2
```sh
kubectl apply -f examples/cluster-peering-yamls-default/acceptor-on-dc1-for-dc2.yaml --context $S1
kubectl get secrets peering-token-dc1-default-dc2-default --context $S1 -oyaml | kubectl apply -f - --context $S2
kubectl apply -f examples/cluster-peering-yamls-default/dialer-dc2-to-dc1.yaml --context $S2
```

## Verify the cluster peering status
```sh
export CONSUL_HTTP_ADDR=$(terraform output -raw consul-dc1-server-fqdn)
export CONSUL_HTTP_TOKEN=$(kubectl get secret -n consul consul-bootstrap-acl-token -ojson --context $S1 | jq .data.token -r | base64 -d)
curl -s -H "Authorization: Bearer $CONSUL_HTTP_TOKEN" -k $CONSUL_HTTP_ADDR/v1/peering/dc2-default\?partition=default | jq .
```

## Delete peering relationships
```
kubectl delete -f examples/cluster-peering-yamls-default/acceptor-on-dc1-for-dc2.yaml --context $S1
kubectl delete -f examples/cluster-peering-yamls-default/dialer-dc2-to-dc1.yaml --context $S2

kubectl delete secrets peering-token-dc1-default-dc2-default --context $S1
kubectl delete secrets peering-token-dc1-default-dc2-default --context $S2

kubectl delete -f examples/cluster-peering-yamls-default/proxy-defaults.yaml --context $S1
kubectl delete -f examples/cluster-peering-yamls-default/proxy-defaults.yaml --context $S2

kubectl delete -f examples/cluster-peering-yamls-default/peer-through-meshgateways.yaml --context $S1
kubectl delete -f examples/cluster-peering-yamls-default/peer-through-meshgateways.yaml --context $S2
```