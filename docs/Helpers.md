# Helpers.tpl File

[TOC]

This document briefly covers the use of \_helpers.tpl file within the helm chart.

\_helpers.tpl is mainly used to define functions ( a piece of re-usable code ) that is used across the helm chart.

> **Note:** To learn more about the use of Helpers, please refer to the following [Helm documentation](https://helm.sh/docs/chart_template_guide/named_templates/)

There must be at least one _helpers.tpl that should be present inside the chart directory.
The files whose name begins with an underscore (_) are assumed to not have a manifest inside.
These files are not rendered to Kubernetes object definitions, but are available everywhere within other chart templates for use.

Before defining a function, the developer must create a heading (as a comment) containing a name that represents the usage of the function.

The below example shows a sample \_helpers.tpl that uses another file named "[eric-product-info.yaml](../charts/__helmChartDockerImageName__/eric-product-info.yaml)", for referring certain values.
This shows that we can call another files from \_helpers.tpl for fetching values.

```
{{/*
Create Ericsson Product Info
*/}}
{{- define "eric-service-assurance.helm-annotations" -}}
ericsson.com/product-name: {{ (fromYaml (.Files.Get "eric-product-info.yaml")).productName | quote }}
ericsson.com/product-number: {{ (fromYaml (.Files.Get "eric-product-info.yaml")).productNumber | quote }}
ericsson.com/product-revision: {{ regexReplaceAll "(.*)[+|-].*" .Chart.Version "${1}" | quote }}
{{- if .Values.annotations }}
{{ toYaml .Values.annotations }}
{{- end }}
{{- end }}

```

Here, the keys, product-name and product-number are derived from the "[eric-product-info.yaml](../charts/__helmChartDockerImageName__/eric-product-info.yaml)".
product-revision is derived from helm's internal function .Chart.Version.

Other parameters like annotations are derived from [values.yaml](../charts/__helmChartDockerImageName__/values.yaml) file.

1. "define" keyword is used to define a function.

```
{{- define "mychart.labels" }}
# body of template here
{{- end }}
```

2. "template" keyword is used to call the defined function.

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-configmap
  {{- template "mychart.labels" }}
```

3. "include" keyword can also be used to call the defined function.

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-configmap
  labels:
  {{ include "mychart.labels" . | indent 4 }}
```
