# eric-product-info File

[TOC]

The [eric-product-info.yaml](../charts/oss-integration-chart-chassis/eric-product-info.yaml) file is included in the root directory of helm chart to provide product and image information as a metadata file.
The metadata file contains the helm chart and all the referenced image product numbers and the default value of container registry URLs.

This file was introduced later in the design rules by the ADP team to make helm charts simpler and reference all the chart image at a singe file.
Hence, all the images must be mentioned in this file along with their tags and repo location.

The helm product name and number are read from the eric-product-info.yaml when creating the ericsson.com/product-number annotations
The default registry url, repository path, rename and tag for each image is read from the eric-product-info.yaml when creating the image url.


| Parameter                   | Description                                                                                |
|-----------------------------|--------------------------------------------------------------------------------------------|
| productName                 | The product name of the helm chart                                                         |
| productNumber               | The product number of the application helm chart                                           |
| images                      | Map of images                                                                              |
| images.\<id\>               | The identifier of an image (SHALL match the identifier used in the helm chart values.yaml) |
| images.\<id\>.productName   | The Product Name of the image                                                              |
| images.\<id\>.productNumber | The Product Number of the image                                                            |
| images.\<id\>.registry      | The default registry url of the image                                                      |
| images.\<id\>.repoPath      | The default repository path                                                                |
| images.\<id\>.name          | The name of the image                                                                      |
| images.\<id\>.tag           | The tag (version) of the image                                                             |


```
productName: "Example Product"
productNumber: "CXD 101 1001"
images:
  mainImage:
    productName: "Example Product Image"
    productNumber: "CXU 101 1995"
    registry: "armdocker.rnd.ericsson.se"
    repoPath: "proj-adp-ref-released"
    name: "eric-ref-main-image"
    tag: "1.0.0-1"
```


1) Only include information for this helm chart, not for the included dependency helm charts.


2) global.registry.url set parameter overrides images.\<id\>.registry when set.


3) imageCredentials.\<id\>.registry.url set parameter overrides images.\<id\>.registry when set


4) imageCredentials.\<id\>.repoPath set parameter overrides images.\<id\>.repoPath when set.


5) The logic of inserting key values from [eric-product-info.yaml](../charts/__helmChartDockerImageName__/eric-product-info.yaml) file into helm chart is mentioned in the [_helpers.tpl](../charts/__helmChartDockerImageName__/templates/_helpers.tpl) file.



```
{{- define "ericsson-service-assurance.apiGatewayClientImagePath" }}
    {{- $productInfo := fromYaml (.Files.Get "eric-product-info.yaml") -}}
    {{- $registryUrl := $productInfo.images.apiGatewayClient.registry -}}
    {{- $repoPath := $productInfo.images.apiGatewayClient.repoPath -}}
    {{- $name := $productInfo.images.apiGatewayClient.name -}}
    {{- $tag := $productInfo.images.apiGatewayClient.tag -}}
    {{- if .Values.global -}}
        {{- if .Values.global.registry -}}
            {{- if .Values.global.registry.url -}}
                {{- $registryUrl = .Values.global.registry.url -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}

...
{{- end -}}
```

Here, a variable named productInfo is defined using the fromYaml function of helm chart that represents contents of eric-product-info file.
There are other keys related to registry's url,  repo's path, repo's name, image's tag that is defined using productInfo variable.

At the end, the logic says that if there is any registry url defined inside global parameters of the values.yaml file of the helm chart, then that value will over-ride the url that comes from eric-product-info file.

In the similar way, (not mentioned in the example above), If other parameters like repoPath, imageCredentials, imageName and Image tags are found in values.yaml of helm chart that those values will override the values taken from eric-product-info.yaml during helm chart execution.
