# Secrets File

[TOC]

The document briefly covers the use of secrets within the Helm Template.

A secret is an object that allows the storage of a small amount of sensitive data which could include a password, API tokens, keys, certificates etc which might otherwise be put in a pod specification or container image.

Secrets can be created independently of Pods that use them, therefore there is less risk of the Secret being exposed during workflow of creating, viewing and editing Pods.

There are multiple ways in order to create a secret using functions within the \_helpers.tpl file.

> **Note:** To learn more about the use of Secrets, please refer to the following [Kubernetes Documentation](https://kubernetes.io/docs/concepts/configuration/secret/)

The Lookup Function uses Helm's existing Kubernetes connection configuration to query Kubernetes, if it finds the secret it will obtain the data from that secret. Otherwise, within our function it will create a Random Number of character.

The derivedPassword Function will look at the .Values file in order to check if the admin-user.credentials exist and will obtain the username and password from the credentials if it does exist. Otherwise, within our function it will create a Random Number of character.

Below showcases data that could be stored in a secret, in this secret we have a key value pair of "example" that contains the value "example-user" encoded in base64.

```
apiVersion: v1
kind: Secret
metadata:
  name: eric-oss-admin-user-secret
  labels:
  {{- include "eric-service-assurance.labels" .| nindent 4 }}
  annotations:
  {{- include "eric-service-assurance.helm-annotations" .| nindent 4 }}
type: Opaque
data:
  example: ""
```

In the example above, we can see a list of parameters that are needed when creating a Secret file:

| Parameter  | Description                                                                                                 | Default |
| ---------- | ----------------------------------------------------------------------------------------------------------- | ------- |
| apiVersion | What version of the Kubernetes API you're using to create the Object                                        | v1      |
| kind       | Which kind of object you want to create.                                                                    | Secret  |
| metadata   | Data that helps uniquely identify the object (Could include name, UID, namespace, labels, annotations etc.) |         |
| data       | Used to store arbitrary data which is encoded using base64.                                                 |         |

Given the example secret above, below is the process of adding a Key-Value Pair to the configuration data:

1. My application wants to be able to add a secret key and password to an admin user within the secret.

2. We must define a Key-Value Pair with the admin user's credentials, below you can see base64 encoded values for the username and password credentials of an admin user that are to be added.

3. There are two ways we can do this either through the use of a lookup function within \_helper.tpl file or the use of a derivedPassword function which obtains the credentials from the .Values file.

4a) An example of the Lookup Function is shown below:

```
{{/*
Define Admin User Credentials - Lookup Example
*/}}
{{- define "eric-service-assurance.lookup-example" -}}
  {{- $secret := (lookup "v1" "Secret" .Release.Namespace "eric-oss-admin-user-secret") -}}
  {{- if $secret }}
    {{ $secret.data.lookupExample }}
  {{- else -}}
    {{- (randAlphaNum 38) | b64enc | quote -}}
  {{- end -}}
{{- end -}}
```

4b) An example of the derivedPassword Function is shown below:

```
{{/*
Define Admin User Credentials - derivedPassword-example
*/}}
{{- define "eric-service-assurance.derivedPassword-example" -}}
  {{- if index .Values "admin-user" "credentials" -}}
    {{- print ( derivePassword 1 "long" .Chart.Name ( index .Values "admin-user" "credentials" ).username ( index .Values "admin-user" "credentials" ).password | b64enc ) -}}
  {{- else -}}
    {{- (randAlphaNum 38) | b64enc | quote -}}
  {{- end -}}
{{- end -}}
```

5. Now that we have the derivedPassword Function and Lookup Function defined, we need to reference the defined functions within the Secret, we can do this by adding the Key-Value Pairs under the data section:

```
deriveExample: {{ include "eric-service-assurance.derivedPassword-example" . }}
lookupExample: {{ include "eric-service-assurance.lookup-example" . }}
```

Which will result in the final Secret that will be used, shown below:

```
apiVersion: v1
kind: Secret
metadata:
  name: eric-oss-admin-user-secret
  labels:
  {{- include "eric-service-assurance.labels" .| nindent 4 }}
  annotations:
  {{- include "eric-service-assurance.helm-annotations" .| nindent 4 }}
type: Opaque
data:
  example: ZXhhbXBsZS11c2VyCg==
  deriveExample: {{ include "eric-service-assurance.derivedPassword-example" . }}
  lookupExample: {{ include "eric-service-assurance.lookup-example" . }}
```

This Secret can then be used within Applications through volumes in order to obtain the configuration settings, an example of a Pod Definition using a Secret can be shown below:

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
  volumes:
  - name: config
    secret:
      secretName: eric-oss-admin-user-secret
```

The application mypod can now access the variables within the secret by referring to the following location within the volume /config/eric-oss-system-user-secret.
