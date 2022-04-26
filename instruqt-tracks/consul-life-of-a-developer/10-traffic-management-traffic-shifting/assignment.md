---
slug: traffic-management-traffic-shifting
id: bdzwgt3pzhsw
type: challenge
title: 'Traffic Management: Traffic Shifting'
teaser: Test multiple versions of your application
tabs:
- title: Workstation
  type: terminal
  hostname: workstation
- title: Consul UI
  type: service
  hostname: workstation
  path: /ui/k8s1/services/payments-api/routing
  port: 8500
- title: K8s Deployment
  type: code
  hostname: workstation
  path: /root/deployments
- title: App
  type: service
  hostname: k8s1
  path: /
  port: 8080
  new_window: true
- title: Vault UI
  type: service
  hostname: k8s1
  path: /
  port: 8200
- title: Lab Architecture
  type: website
  url: https://htmlpreview.github.io/?https://raw.githubusercontent.com/hashicorp/field-workshops-consul/master/instruqt-tracks/consul-life-of-a-developer/assets/diagrams/diagrams.html
difficulty: basic
timelimit: 500
---
Review the routes and apply the routing configuration.  <br>

```
kubectl config use-context k8s1
kubectl apply -f v2
sleep 5
kubectl wait pod --for=condition=Ready --selector=app=payments-api,version=v2 --timeout=90s
```

Validate that the traffic shifting rules have been applied, and the weights are correct.

```
kubectl exec deploy/public-api -c envoy-sidecar -- wget -qO- 127.0.0.1:19000/clusters
kubectl exec deploy/public-api -c envoy-sidecar -- wget -qO- 127.0.0.1:19000/config_dump | jq '[.. |."routes"? | select(. != null)][-1]'
```

Query the payment API a few times.
You will see a mix of unencrypted and encrypted records. <br>


Get the endpoint. <br>

```
kubectl describe svc consul-ingress-gateway
ip=$(kubectl get svc consul-ingress-gateway -o json | jq -r '.status.loadBalancer.ingress[0].ip')
```

Try the API. Run the command a few times to see the difference in the encrypted and non-encrypted values. <br>

```
curl -s -v http://${ip}:8080/api \
-H 'Accept-Encoding: gzip, deflate, br' \
-H 'Content-Type: application/json' \
-H 'Accept: application/json' \
-H 'Connection: keep-alive' \
-H 'DNT: 1' \
--data-binary '{"query":"mutation{ pay(details:{ name: \"nic\", type: \"mastercard\", number: \"1234123-0123123\", expiry:\"10/02\", cv2: 1231, amount: 12.23 }){id, card_plaintext, card_ciphertext, message } }"}' \
--compressed | jq
```

If you are getting 200 responses, you can cut over the rest of the traffic to the encrypted solution. <br>

```
cat <<EOF | kubectl apply -f -
apiVersion: consul.hashicorp.com/v1alpha1
kind: ServiceSplitter
metadata:
  name: payments-api
spec:
  splits:
    - weight: 0
      serviceSubset: v1
    - weight: 100
      serviceSubset: v2
EOF
```

Check that the v2 service is now 100% weighted. <br>

```
kubectl exec deploy/public-api -c envoy-sidecar -- wget -qO- 127.0.0.1:19000/config_dump | jq '[.. |."routes"? | select(. != null)][-1]'
```

Now that each record will be encrypted, validate in the redis cache that the value in the queue is indeed ciphertexts.

```
kubectl config use-context k8s1
id=$(curl -s http://${ip}:8080/api -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'DNT: 1' --data-binary '{"query":"mutation{ pay(details:{ name: \"nic\", type: \"mastercard\", number: \"1234123-0123123\", expiry:\"10/02\", cv2: 1231, amount: 12.23 }){id, card_plaintext, card_ciphertext, message } }"}' --compressed | jq  -r .data.pay.id)
kubectl config use-context k8s2
kubectl exec statefulset/payments-queue -- redis-cli HGET "payment:${id}" "cc.number"
```

You will collect some metrics and traces from the new application in the new few exercises.
