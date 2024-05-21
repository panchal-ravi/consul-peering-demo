
## Reset
kubectl delete -f search/product-dc2-resolver.yml --context $S1
kubectl delete -f search/product-failover.yml --context $S1
kubectl delete -f search/product-splitter.yml --context $S1
kubectl apply -f search/product-v1-local.yml --context $S1
kubectl apply -f search/service-intentions-product.yml --context $S1
