#!/bin/bash
while true; do kubectl --context $S1 exec -i $(kubectl get pod -l app=search -oname --context $S1) -c search -- curl -s localhost:9090 | jq '.upstream_calls[] | "\(.name), \(.code)"' -r; sleep 1; done
