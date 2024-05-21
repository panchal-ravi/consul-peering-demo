kubectl apply -f search/product-dc2-resolver.yml --context $S1
kubectl apply -f search/product-failover.yml --context $S1
kubectl apply -f search/product-splitter.yml --context $S1
