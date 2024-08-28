# Virtual Service file

[TOC]

Virtual-service file mainly deals with the traffic controlling of the incoming and outgoing traffic from the application containers.
[virtual-service.yaml](../charts/__helmChartDockerImageName__/templates/ingresses/eric-samplehost-virtualservice.yaml) contains the set of rules that defines the control of the network traffic.

An incoming or outgoing request passes through the proxy (that are based out of [envoy](https://www.envoyproxy.io/)) first and then reaches virtual service that re-directs the traffic based on rules.

> **Note:** You must have a [Gateway](Gateway.md) defined in order to create Virtual Services. Both, Gateway and Virtual-Services are deployed as pod using Kubernetes CRD.

> **Note:** To learn more about the use of Virtual Services, please refer to the following [Istio documentation](https://istio.io/latest/docs/reference/config/networking/virtual-service/)

```
{{- if and (eq $serviceMesh "true") (eq $serviceMeshIngress "true") -}}
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: {{ template "eric-service-assurance.name" . }}-gas-virtualservice
  annotations:
  {{- include "eric-service-assurance.helm-annotations" .| nindent 4 }}
  labels:
  {{- include "eric-service-assurance.labels" .| nindent 4 }}
spec:
  gateways:
  - {{ template "eric-service-assurance.name" . }}-gas-gateway
  hosts:
  - {{ required "A valid .Values.global.hosts.gas entry required" .Values.global.hosts.gas }}
  http:
  - name: gas
    match:
    - uri:
        prefix: /
    route:
    - destination:
        host: eric-eo-api-gateway
        port:
          number: 80
{{- end }}
```

In the example above, we can see a list of parameters that are needed when creating a ConfigMap file:

| Parameter  | Description                                                                                                                                                                                          | Default                                                                                                                                            |
| ---------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| apiVersion | What version of the Kubernetes API you're using to create the Object                                                                                                                                 | networking.istio.io/v1beta1                                                                                                                        |
| kind       | "Virtual-service" is kind of CRD, or in other words an extendable plugin offered by Kubernetes.                                                                                                      | VirtualService                                                                                                                                     |
| metadata   | Data that helps uniquely identify the object (Could include name, UID, namespace, labels, annotations etc.)                                                                                          |                                                                                                                                                    |
| spec       | Contains the keys that are required to define the set of rule. The keys mainly include gateway that is pointing to, hosts on which it is applicable, and protocol name on which the rule is applied. | List of other keys can be found in [Istio documentation](https://istio.io/latest/docs/reference/config/networking/virtual-service/#VirtualService) |

Given the example shown above, the following is the steps that would be needed in order to add a Microservice to a Virtual Service to allow for re-routing based on the URL given:

1. Let's say we want to add a URL route to the GAS host, in order to re-route traffic (From the Gateway) to the Microservice health-checker if the prefix "/health-check" is given.

2. To achieve this we would have to add the following parameters in the Virtual Service file.

The variables down below showcase that traffic that enters the GAS application with the "/health-check" url will be re-routed to the health-checker Microservice.

```
http:
- name: gas
  match:
    - uri:
      prefix: /health-check
      route:
        - destination:
          host: health-checker
          port:
          number: 81
```

Which would end up with a resulting Virtual Service with the change included, which will be attached to the GAS gateway:

```
{{- if and (eq $serviceMesh "true") (eq $serviceMeshIngress "true") -}}
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: {{ template "eric-service-assurance.name" . }}-gas-virtualservice
  annotations:
  {{- include "eric-service-assurance.helm-annotations" .| nindent 4 }}
  labels:
  {{- include "eric-service-assurance.labels" .| nindent 4 }}
spec:
  gateways:
  - {{ template "eric-service-assurance.name" . }}-gas-gateway
  hosts:
  - {{ required "A valid .Values.global.hosts.gas entry required" .Values.global.hosts.gas }}
  http:
  - name: gas
    match:
    - uri:
        prefix: /
    route:
    - destination:
        host: eric-eo-api-gateway
        port:
          number: 80
    match:
    - uri:
        prefix: /health-check
    route:
    - destination:
        host: health-checker
        port:
          number: 81
{{- end }}
```
