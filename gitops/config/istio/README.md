# Istio

Service mesh and ingress gateway deployed via the [istio](https://istio-release.storage.googleapis.com/charts) Helm chart.

## How It Works

Istio provides traffic management, observability and security for services in the cluster. All external traffic enters through the `istio-ingressgateway` LoadBalancer service.

```
Internet → LoadBalancer → Istio IngressGateway → VirtualService → Service → Pod
```

## No Vault Secret Required

Istio does not require any secrets to operate.

## Exposing an Application

To expose an application externally, create a `Gateway` and `VirtualService` in the application's namespace:

```yaml
apiVersion: networking.istio.io/v1
kind: Gateway
metadata:
  name: myapp
  namespace: myapp
  annotations:
    external-dns.alpha.kubernetes.io/hostname: myapp.example.com
spec:
  selector:
    istio: ingressgateway
  servers:
    - port:
        number: 443
        name: https
        protocol: HTTPS
      tls:
        mode: SIMPLE
        credentialName: myapp-tls
      hosts:
        - myapp.example.com
    - port:
        number: 80
        name: http
        protocol: HTTP
      tls:
        httpsRedirect: true
      hosts:
        - myapp.example.com
---
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: myapp
  namespace: myapp
spec:
  hosts:
    - myapp.example.com
  gateways:
    - myapp
  http:
    - route:
        - destination:
            host: myapp
            port:
              number: 8080
```

The `external-dns.alpha.kubernetes.io/hostname` annotation on the Gateway triggers ExternalDNS to create the DNS record automatically.
