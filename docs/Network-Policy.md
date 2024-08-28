# Network Policy File

[TOC]

The document briefly covers the use of a network policies within the Helm Template.

Network policies can be used to control traffic flow at the IP Address or port level (OSI Layer 3/4).

Network policies are an application-centric construct that will allow you to specify how a pod is allowed to communicate with various network entities over the network.

When defining a pod based or namespace based network policy, you must use a selector to specify which traffic is allowed to and from the pod that match the selector.

> **Note:** To learn more about the use of Network Policies, please refer to the following [Kubernetes Documentation](https://kubernetes.io/docs/concepts/services-networking/network-policies/)

The entities that a Pod can communicate with are identified through a combination of the following 3 identifiers:

1. Other pods that are allowed (pod cannot block access to itself)

2. Namespaces that are allowed

3. IP Blocks

By default, a pod is non-isolated for ingress meaning all inbound connections are allowed.

A pod is isolated for ingress if there is any network policies that both selects the pod and has "Ingress" in its policyTypes.

When a pod is isolated for ingress, that means the only allowed connections into the pod are those from the pod's worker node and those allowed by the ingress list of the network policy that are applied to the pod.

By default, a pod is non-isolated for egress meaning all outbound connections are allowed.

A pod is isolated for egress if there is any Network Policies that both selects the Pod and has "Egress" in its policyTypes.

When a pod is isolated for egress, that means the only allowed connections into the Pod are those from the Pod's worker node and those allowed by the egress list of the Network Policy that are applied to the Pod.

```
{{ if .Values.global.networkPolicy.enabled -}}
{{ $pmserver := include "eric-service-assurance.eric-pm-server.enabled" . }}
{{ if eq $pmserver "true" -}}
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: {{ template "eric-service-assurance.name" . }}-eric-pm-server-policy
  labels:
  {{- include "eric-service-assurance.labels" .| nindent 4 }}
  annotations:
  {{- include "eric-service-assurance.helm-annotations" .| nindent 4 }}
spec:
  podSelector:
    matchLabels:
      app: eric-pm-server
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: eric-eo-api-gateway
{{- end }}
{{- end }}
```

In the example above, we can see a list of parameters that are needed when creating a Secret file:

| Parameter   | Description                                                                                                                           | Default                                                                                       |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| apiVersion  | What version of the Kubernetes API you're using to create the Object                                                                  | networking.k8s.io/v1                                                                          |
| kind        | Which kind of object you want to create.                                                                                              | NetworkPolicy                                                                                 |
| metadata    | Data that helps uniquely identify the object (Could include name, UID, namespace, labels, annotations etc.)                           |                                                                                               |
| spec        | Contains the information needed to define a particular Network Policy in the given namespace.                                         |                                                                                               |
| podSelect   | PodSelector is used to select the grouping of pods to which the policy applies.                                                       | Empty, will select all pods in the namespace.                                                 |
| policyTypes | Indicates whether or not the given policy applies to ingress traffic to the selected Pod, egress traffic to the selected Pod or both. | Ingress will always be set and Egress will be set if the Network Policy has any egress rules. |
| ingress     | Allows traffic which matches both the "from" and "ports" sections.                                                                    |                                                                                               |
| egress      | Allows traffic which matches both the "to" and "ports" sections.                                                                      |                                                                                               |

Below specifies how you can identify a Pod to add to an ingress/egress list:

| Parameter                       | Description                                                                                                                                                                                        |
| ------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| podSelector                     | Allows you to select particular Pods in the same namespace as the Network Policy which should be allowed as ingress sources or egress destinations.                                                |
| namespaceSelector               | Allows you to select particular namespaces for which all Pods should be allowed as ingress sources/egress destinations.                                                                            |
| podSelector & namespaceSelector | A single to/from entry that specifies both namespaceSelector and podSelector to select particular Pods within particular namespaces that should be allowed as ingress sources/egress destinations. |
| ipBlock                         | Allows you to select particular IP CIDR ranges to allow as ingress sources or egress destinations.                                                                                                 |

Given the example network policy above, below is the process of adding allowing an extra ingress & egress connection:

1. Our application needs to allow outgoing connections from the eric-eo-common-br-agent application.

2. In order to allow for the communication between our Pod and eric-eo-common-br-agent application, we must add a Pod Selector to the Egress key to find any Pods that match the label eric-eo-common-br-agent, which would result in the values shown below:

```
egress:
- to:
  - podSelector:
      matchLabels:
        app: eric-eo-common-br-agent
```

Once the following value is added, this will result in the Network Policy shown below:

```
{{ if .Values.global.networkPolicy.enabled -}}
{{ $pmserver := include "eric-service-assurance.eric-pm-server.enabled" . }}
{{ if eq $pmserver "true" -}}
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: {{ template "eric-service-assurance.name" . }}-eric-pm-server-policy
  labels:
  {{- include "eric-service-assurance.labels" .| nindent 4 }}
  annotations:
  {{- include "eric-service-assurance.helm-annotations" .| nindent 4 }}
spec:
  podSelector:
    matchLabels:
      app: eric-pm-server
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: eric-eo-api-gateway
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: eric-eo-common-br-agent
{{- end }}
{{- end }}
```
