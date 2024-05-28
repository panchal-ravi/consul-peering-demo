# Deploy services in dc1 and dc2

## Apply samenessgroup
kaf ./examples/applications/prepared-query/sameness-group-dc1-default.yml --context $S1
kaf ./examples/applications/prepared-query/sameness-group-dc2-default.yml --context $S2

## Deploy services
kubectl label ns default consul=enabled --context $S1
kubectl label ns default consul=enabled --context $S2
kaf ./examples/applications/prepared-query/search.yml --context $S1
kaf ./examples/applications/prepared-query/search.yml --context $S2
kaf ./examples/applications/prepared-query/product.yml --context $S1
kaf ./examples/applications/prepared-query/product.yml --context $S2

## Export services
kaf ./examples/applications/prepared-query/export-product.yml --context $S1
kaf ./examples/applications/prepared-query/export-product.yml --context $S2


# Create prepared query in dc1-default
export CONSUL_HTTP_ADDR1=$(terraform output -raw consul-dc1-server-fqdn)
export CONSUL_HTTP_TOKEN1=$(kubectl get secret -n consul consul-bootstrap-acl-token -ojson --context $S1 | jq .data.token -r | base64 -d)

curl -k \
    -H "Authorization: Bearer $CONSUL_HTTP_TOKEN1" \
    --request POST \
    --data @examples/applications/prepared-query/prepared-query.json \
    $CONSUL_HTTP_ADDR1/v1/query

## List prepared query
curl -ks -H "Authorization: Bearer $CONSUL_HTTP_TOKEN1" $CONSUL_HTTP_ADDR1/v1/query


## Execute prepared query
export QUERY_ID1=$(curl -sk -H "Authorization: Bearer $CONSUL_HTTP_TOKEN1" $CONSUL_HTTP_ADDR1/v1/query | jq ".[].ID" -r)
curl -ks -H "Authorization: Bearer $CONSUL_HTTP_TOKEN1" $CONSUL_HTTP_ADDR1/v1/query/$QUERY_ID1/execute

# Create prepared query in dc2-default
export CONSUL_HTTP_ADDR2=$(terraform output -raw consul-dc2-server-fqdn)
export CONSUL_HTTP_TOKEN2=$(kubectl get secret -n consul consul-bootstrap-acl-token -ojson --context $S2 | jq .data.token -r | base64 -d)

curl -k \
    -H "Authorization: Bearer $CONSUL_HTTP_TOKEN2" \
    --request POST \
    --data @examples/applications/prepared-query/prepared-query.json \
    $CONSUL_HTTP_ADDR2/v1/query

## List prepared query
curl -ks -H "Authorization: Bearer $CONSUL_HTTP_TOKEN2" $CONSUL_HTTP_ADDR2/v1/query


## Execute prepared query
export QUERY_ID2=$(curl -sk -H "Authorization: Bearer $CONSUL_HTTP_TOKEN2" $CONSUL_HTTP_ADDR2/v1/query | jq ".[].ID" -r)
curl -ks -H "Authorization: Bearer $CONSUL_HTTP_TOKEN2" $CONSUL_HTTP_ADDR2/v1/query/$QUERY_ID2/execute


# DNS lookup/failover scenarios

## DC1
kgp --context $S1 | grep -i search | awk '{print $1}' | xargs -I{} kubectl exec -i {} -c search --context $S1 -- dig product.query.consul +short
k scale deployment product-v1 --replicas 0 --context $S1
kgp --context $S1 | grep -i search | awk '{print $1}' | xargs -I{} kubectl exec -i {} -c search --context $S1 -- dig product.query.consul +short
k scale deployment product-v1 --replicas 1 --context $S1

## DC2
kgp --context $S2 | grep -i search | awk '{print $1}' | xargs -I{} kubectl exec -i {} -c search --context $S2 -- dig product.query.consul +short
k scale deployment product-v1 --replicas 0 --context $S2
kgp --context $S2 | grep -i search | awk '{print $1}' | xargs -I{} kubectl exec -i {} -c search --context $S2 -- dig product.query.consul +short
k scale deployment product-v1 --replicas 1 --context $S2

## Delete All

kdelf ./examples/applications/prepared-query/export-product.yml --context $S1
kdelf ./examples/applications/prepared-query/export-product.yml --context $S2
kdelf ./examples/applications/prepared-query/search.yml --context $S1
kdelf ./examples/applications/prepared-query/search.yml --context $S2
kdelf ./examples/applications/prepared-query/product.yml --context $S1
kdelf ./examples/applications/prepared-query/product.yml --context $S2
kdelf ./examples/applications/prepared-query/sameness-group-dc1-default.yml --context $S1
kdelf ./examples/applications/prepared-query/sameness-group-dc2-default.yml --context $S2

curl -ks -X DELETE -H "Authorization: Bearer $CONSUL_HTTP_TOKEN1" $CONSUL_HTTP_ADDR1/v1/query/$QUERY_ID1
curl -ks -X DELETE -H "Authorization: Bearer $CONSUL_HTTP_TOKEN2" $CONSUL_HTTP_ADDR2/v1/query/$QUERY_ID2
