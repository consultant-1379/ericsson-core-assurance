
# # This file is used to define functions than can be re-used inside the helm templates/chart.
# # In the example below, it can be seen that two keys i.e. product-name and product-number are being referred from eric-product-info.yaml file.
# # The name of the function is "helm-annotations" that can be called from within the chart.
# # Detailed explanation of this file can be found in docs/Helper.md

{{/*
Expand the name of the chart.
*/}}
{{- define "eric-service-assurance.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create Ericsson product labels info
*/}}
{{- define "eric-service-assurance.labels" -}}
app.kubernetes.io/name: {{ include "eric-service-assurance.name" . }}
app.kubernetes.io/version: {{ .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- if .Values.labels }}
  {{ toYaml .Values.labels }}
{{- end}}
{{- end -}}

{{/*
Create Ericsson Product Info
*/}}
{{- define "eric-service-assurance.helm-annotations" }}
ericsson.com/product-name: {{ (fromYaml (.Files.Get "eric-product-info.yaml")).productName | quote }}
ericsson.com/product-number: {{ (fromYaml (.Files.Get "eric-product-info.yaml")).productNumber | quote }}
ericsson.com/product-revision: {{ regexReplaceAll "(.*)[+|-].*" .Chart.Version "${1}" | quote }}
{{- if .Values.annotations }}
  {{ toYaml .Values.annotations }}
{{- end }}
{{- end -}}

{{/*
Create Ericsson product app.kubernetes.io info
*/}}
{{- define "eric-service-assurance.kubernetes-io-info" -}}
app.kubernetes.io/name: {{ .Chart.Name | quote }}
app.kubernetes.io/version: {{ .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- end -}}

{{/*
Create a map from ".Values.global" with defaults if missing in values file.
This hides defaults from values file.
*/}}
{{ define "ericsson-service-assurance.global" }}
  {{- $globalDefaults := dict "security" (dict "tls" (dict "enabled" true)) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "nodeSelector" (dict)) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "registry" (dict "url" "armdocker.rnd.ericsson.se")) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "pullSecret" "") -}}
  {{ if .Values.global }}
    {{- mergeOverwrite $globalDefaults .Values.global | toJson -}}
  {{ else }}
    {{- $globalDefaults | toJson -}}
  {{ end }}
{{ end }}

{{/*
Define Admin User Credentials - derivedPassword Example
*/}}
{{- define "eric-service-assurance.derivedPassword-example" -}}
  {{- if index .Values "defaultUser" -}}
    {{- print ( derivePassword 1 "long" .Chart.Name ( index .Values "defaultUser" ).username ( index .Values "defaultUser" ).password | b64enc ) -}}
  {{- else -}}
    {{- (randAlphaNum 38) | b64enc | quote -}}
  {{- end -}}
{{- end -}}

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

{{/*
Create release name used for cluster role.
*/}}
{{- define "eric-service-assurance.release.name" -}}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

# Below function is referring to the values.yaml file of this chat. But it is recommended to make changes in the gotmpl files as mentioned in documentation
{{/*
    check global.security.tls.enabled since it is removed from values.yaml
*/}}
{{- define "eric-service-assurance.global-security-tls-enabled" -}}
{{- if  .Values.global -}}
  {{- if  .Values.global.security -}}
    {{- if  .Values.global.security.tls -}}
        {{- .Values.global.security.tls.enabled | toString -}}
    {{- else -}}
        {{- "false" -}}
    {{- end -}}
  {{- else -}}
      {{- "false" -}}
  {{- end -}}
{{- else -}}
  {{- "false" -}}
{{- end -}}
{{- end -}}

{{/*
Define image path
*/}}

{{- define "eric-service-assurance.imagePath" -}}
    {{- $productInfo := fromYaml (.Files.Get "eric-product-info.yaml") -}}
    {{- $registryUrl := (index $productInfo "images" .imageName "registry") -}}
    {{- $repoPath := (index $productInfo "images" .imageName "repoPath") -}}
    {{- $name := (index $productInfo "images" .imageName "name") -}}
    {{- $tag := (index $productInfo "images" .imageName "tag") -}}
    {{- if .Values.global -}}
        {{- if .Values.global.registry -}}
            {{- if .Values.global.registry.url -}}
                {{- $registryUrl = .Values.global.registry.url -}}
            {{- end -}}
            {{- if not (kindIs "invalid" .Values.global.registry.repoPath) -}}
                {{- $repoPath = .Values.global.registry.repoPath -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if .Values.imageCredentials -}}
        {{- if not (kindIs "invalid" .Values.imageCredentials.repoPath) -}}
            {{- $repoPath = .Values.imageCredentials.repoPath -}}
        {{- end -}}
        {{- if (index .Values "imageCredentials" .imageName) -}}
            {{- if (index .Values "imageCredentials" .imageName "registry") -}}
                {{- if (index .Values "imageCredentials" .imageName "registry" "url") -}}
                    {{- $registryUrl = (index .Values "imageCredentials" .imageName "registry" "url") -}}
                {{- end -}}
            {{- end -}}
            {{- if not (kindIs "invalid" (index .Values "imageCredentials" .imageName "repoPath")) -}}
                {{- $repoPath = (index .Values "imageCredentials" .imageName "repoPath") -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if $repoPath -}}
        {{- $repoPath = printf "%s/" $repoPath -}}
    {{- end -}}
    {{- printf "%s/%s%s:%s" $registryUrl $repoPath $name $tag -}}
{{- end -}}

{{/*
Create the FQDN url to be used by the ESA services
*/}}
{{- define "eric-service-assurance.fqdn" -}}
{{- $fqdnPrefix := .Values.ingress.fqdnPrefix -}}
{{- $chartName := .Chart.Name -}}
{{- if index .Values.global.hosts $chartName  -}}
  {{- $fqdn := index .Values.global.hosts $chartName -}}
  {{- printf "%s" $fqdn }}
{{- else -}}
  {{- $baseHostname := .Values.global.ingress.baseHostname | required "global.ingress.baseHostname is mandatory" -}}
  {{- printf "%s.%s" $fqdnPrefix $baseHostname }}
{{- end -}}
{{- end -}}

{{/*
Create the ingressClass to be used by the ESA services
*/}}
{{- define "eric-service-assurance.ingressClass" -}}
{{- if .Values.ingress.ingressClass -}}
  {{- printf "%s" .Values.ingress.ingressClass -}}
{{- else -}}
  {{- $ingressClass := .Values.global.ingress.ingressClass | required "global.ingress.ingressClass is mandatory" -}}
  {{- printf "%s" $ingressClass -}}
{{- end -}}
{{- end -}}

{{/*
Enable Node Selector functionality
*/}}
{{- define "eric-service-assurance.nodeSelector" -}}
{{- if .Values.nodeSelector }}
nodeSelector:
  {{ toYaml .Values.nodeSelector | trim }}
{{- else if .Values.global.nodeSelector }}
nodeSelector:
  {{ toYaml .Values.global.nodeSelector | trim }}
{{- end }}
{{- end -}}

{{/*
Define tolerations to comply to DR-D1120-060 and DR-D1120-061
*/}}
{{- define "eric-service-assurance.tolerations" -}}
  {{- $tolerations := (list) -}}
  {{- if .Values.tolerations -}}
    {{- if ne (len (index .Values "tolerations") ) 0 -}}
      {{- range $t := (index .Values "tolerations") -}}
        {{- $tolerations = append $tolerations $t -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- if .Values.global -}}
    {{- if .Values.global.tolerations -}}
      {{- if ne (len .Values.global.tolerations) 0 -}}
        {{- range $t := .Values.global.tolerations -}}
          {{- $tolerations = append $tolerations $t -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- toYaml $tolerations}}
{{- end -}}

{{/*
Create Service Mesh enabling option
*/}}
{{- define "eric-service-assurance.service-mesh-enabled" -}}
{{ if .Values.global.serviceMesh }}
  {{ if .Values.global.serviceMesh.enabled }}
    {{- print "true" -}}
  {{ else }}
    {{- print "false" -}}
  {{- end -}}
{{ else }}
  {{- print "false" -}}
{{ end }}
{{- end}}