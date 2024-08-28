# ConfigMap File

[TOC]

The document briefly covers the use of a ConfigMaps within the Helm Template.

ConfigMaps contain key-value pairs which are used to define application or environment specific configuration settings (Hostnames, URLs, Credentials etc.) for Kubernetes objects to use.

The goals are to decouple application and Pod configurations in order to maximise the container image's portability.

> **Note:** To learn more about the use of ConfigMaps, please refer to the following [Kubernetes Documentation](https://kubernetes.io/docs/concepts/configuration/configmap/)

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ template "eric-service-assurance.name" . }}-sample-data
  labels:
    {{- include "eric-service-assurance.labels" .| nindent 4 }}
  annotations:
    {{- include "eric-service-assurance.helm-annotations" .| nindent 4 }}
data:
  sampleData: sampleData
```

In the example above, we can see a list of parameters that are needed when creating a ConfigMap file:

| Parameter  | Description                                                                                                 | Default   |
| ---------- | ----------------------------------------------------------------------------------------------------------- | --------- |
| apiVersion | What version of the Kubernetes API you're using to create the Object                                        | v1        |
| kind       | Which kind of object you want to create.                                                                    | ConfigMap |
| metadata   | Data that helps uniquely identify the object (Could include name, UID, namespace, labels, annotations etc.) |           |
| data       | Key-Value Pairs designed to contain UTF-8 Strings                                                           |           |

Given the example ConfigMap above, below is the process of adding a Key-Value Pair to the configuration data:

1. My application wants to be able to configure the number of retry attempts for the eric-oss-notification-service-database-pg-exclusions.

2. We must define a Key-Value Pair for retry attempts within the data section of the ConfigMap (eric-oss-notification-service-database-pg-exclusions):

```
retry-attempts: 3
```

Once, we add the Key-Value Pair shown above, the resulting ConfigMap will be shown below:

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ template "eric-service-assurance.name" . }}-sample-data
  labels:
    {{- include "eric-service-assurance.labels" .| nindent 4 }}
  annotations:
    {{- include "eric-service-assurance.helm-annotations" .| nindent 4 }}
data:
  sampleData: sampleData
  retry-attempts: 3
```

This ConfigMap can then be used within Applications through volumes in order to obtain the configuration settings, an example of a Pod Definition using a ConfigMap can be shown below:

```
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: redis
    volumeMounts:
    - name: config
      mountPath: "/config"
      readOnly: true
  volumes:
  - name: config
    configMap:
      name: ericsson-service-assurance-sample-data
```

The Application mypod can now access the variables defined within the ConfigMap by referring to the following volume location /config/eric-oss-notification-service-database-pg-exclusions.

> **Note:** ConfigMaps are meant for plain data, and secrets are meant for data that you don't want anything or anyone to know about except the application.
>
> However, secrets can be encrypted using Kubernetes EncryptionConfiguration.
