# Ingress Controller File

[TOC]

The document briefly covers the use of Ingress Controllers within the Helm Template.

In order for the Ingress Resource to work, the cluster must have an Ingress Controller running.

An Ingress Controller is a specialized load balancer for Kubernetes. It abstracts away the complexity of Kubernetes application traffic routing and provides a bridge between Kubernetes services and external ones.

> **Note:** To learn more about the use of Ingress, please refer to the following [Istio Documentation](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)

Kubernetes Ingress Controllers:

- Accept traffic from outside the Kubernetes platform, and load balance it to pods (containers) running inside the platform.

- Can manage egress traffic within a cluster for services which need to communicate with other services outside a cluster.

- Are configured using the Kubernetes API to deploy objects called "Ingress Resources"

- Monitor the pods running in Kubernetes and automatically update the load-balancing rules when pods are added/removed from a service.

```
{{- if .Values.global.iccrAppIngresses }}
apiVersion: projectcontour.io/v1
kind: HTTPProxy
metadata:
  annotations:
    kubernetes.io/ingress.class: {{.Values.global.ingressClass | quote }}
  labels:
    {{- include "eric-service-assurance.labels" .| nindent 4 }}
  name: eric-adp-gui-aggregator-service-ingress-iccr
spec:
  virtualhost:
    fqdn: {{ required "A valid .Values.global.hosts.gas entry required" .Values.global.hosts.gas }}
    tls:
      secretName: {{ required "A valid .Values.ingress.tls.secretName entry required" .Values.ingress.tls.secretName }}
  routes:
  - conditions:
    - prefix: /
    services:
    - name: eric-eo-api-gateway
      port: 80
{{- end }}
```

In the example above, we can see a list of parameters that are needed when creating a Secret file:

| Parameter        | Description                                                                                                           | Default              |
| ---------------- | --------------------------------------------------------------------------------------------------------------------- | -------------------- |
| apiVersion       | What version of the Kubernetes API you're using to create the Object                                                  | projectcontour.io/v1 |
| kind             | Which kind of object you want to create.                                                                              | HTTPProxy            |
| metadata         | Data that helps uniquely identify the object (Could include name, UID, namespace, labels, annotations etc.)           |                      |
| spec             | Contains the information needed to define an Ingress Controller.                                                      |                      |
| virtualhost.fqdn | Represents the domain name from which traffic is gathered.                                                            |                      |
| tls              | Allows access to the TLS Secret which will provide the tls key and tls cert to provide secure passing of information. |                      |
| routes           | Evaluates the rules and manages the redirections to the routes given.                                                 |                      |

Given the example above, and the information we have received, we can go through the process of adding a route for the health-checker service:

1. Given that we know the following information:

| Key          | Description                                                                 | Value          |
| ------------ | --------------------------------------------------------------------------- | -------------- |
| Path/Prefix  | The URL path that is used as an entrypoint into the health-checker service. | /health-check  |
| Service.Name | The name of the service.                                                    | health-checker |
| Service.Port | The entry Port of the service.                                              | 81             |

2. Now that we have obtained the following information, we can create a new route in the Ingress Controller that will accept traffic and will load balance the traffic to Pods that are running the required service.

This can be done by adding the following parameters to the Ingress Controller under the Routes section:

```
- conditions:
  - prefix: /health-check
  services:
  - name: health-checker
    port: 81
```

Which will result in the following Ingress Controller that will allow routing to the health-checker service for external use:

```
{{- if .Values.global.iccrAppIngresses }}
apiVersion: projectcontour.io/v1
kind: HTTPProxy
metadata:
  annotations:
    kubernetes.io/ingress.class: {{.Values.global.ingressClass | quote }}
  labels:
    {{- include "eric-service-assurance.labels" .| nindent 4 }}
  name: eric-adp-gui-aggregator-service-ingress-iccr
spec:
  virtualhost:
    fqdn: {{ required "A valid .Values.global.hosts.gas entry required" .Values.global.hosts.gas }}
    tls:
      secretName: {{ required "A valid .Values.ingress.tls.secretName entry required" .Values.ingress.tls.secretName }}
  routes:
  - conditions:
    - prefix: /
    services:
    - name: eric-eo-api-gateway
      port: 80
  - conditions:
    - prefix: /health-check
    services:
    - name: health-checker
      port: 81
{{- end }}
```
