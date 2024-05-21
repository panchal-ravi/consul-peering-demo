kubectl apply -f search/product-v1-local-failing.yml --context $S1
kubectl apply -f search/product-failover.yml --context $S1
