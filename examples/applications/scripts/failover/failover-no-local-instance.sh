kubectl scale deployment product-v1 --replicas 0 --context $S1

kubectl apply -f search/product-failover.yml --context $S1
