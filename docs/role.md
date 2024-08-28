# Role File

[TOC]

The document briefly covers the use of a Role within the Helm Template.

An RBAC Role or ClusterRole contains rules that represent a set of permissions.
Permissions are purely additive (there are no "deny" rules).

> **Note:** To learn more about the use of Roles, please refer to the following [Kubernetes Documentation](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#role-and-clusterrole)

```
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: {{ template "eric-service-assurance.release.name" . }}-gas-patcher-policy
  labels:
    {{- include "eric-service-assurance.labels" .| nindent 4 }}
  annotations:
    {{- include "eric-service-assurance.helm-annotations" .| nindent 4 }}
rules:
  # Rule to allow GAS hook to patch its ext app configmap
  - apiGroups:
      - "" # "" indicates the core API group
    resources:
      - configmaps
    verbs:
      - get
      - list
      - patch
      - create
      - delete

```

In the example above, we can see a list of parameters that are needed when creating a Secret file:

| Parameter  | Description                                                                                                                                                                                                                                                                                               |
| ---------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| apiVersion | What version of the Kubernetes API you're using to create the Object                                                                                                                                                                                                                                      |
| kind       | Which kind of object you want to create. Here it is "Role".                                                                                                                                                                                                                                               |
| metadata   | Data that will uniquely identify this role (Could include name, UID, namespace, labels, annotations etc.)                                                                                                                                                                                                 |
| rules      | Contains 3 keys i.e. apiGroups, resources and verbs. apigroups: Refers to the group of api/kubernetes resources where this rule will be applied. resources: The kubernetes object on which this role will be applied. verbs: The actions that are applicable to be performed on the Kubernetes resources. |

As an example, lets create a role named ericsson-service-assurance-role in the core api group with "get" and "list" permissions.
The definition file would like as below:

```
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: ericsson-service-assurance-role
rules:
  # Rule to allow GAS hook to patch its ext app configmap
  - apiGroups:
      - "" # "" indicates the core API group
    resources:
      - configmaps
    verbs:
      - get
      - list
```

If we want to include one more K8s resources (e.g. pods) just add below lines.

```
rules:
  # Rule to allow GAS hook to patch its ext app configmap
  - apiGroups:
      - "" # "" indicates the core API group
    resources:
      - pods
    verbs:
      - get
      - list

```

```
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: ericsson-service-assurance-role
rules:
    resources:
      - pods
      - configmaps
    verbs:
      - get
      - list
```
