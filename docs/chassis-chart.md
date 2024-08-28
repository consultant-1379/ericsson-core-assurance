# Ericsson Core Assurance

[TOC]

This document describes the integration chart for Ericsson Core Assurance.
It is a Helm 3 chart structure which means that there is no requirements.yaml file - dependencies are described within the Chart.yaml.

The key files can be described as follows:



This file contains the main information to describe the Chart which includes the versioning and name
This file contains the configurable values that are available for this Chart. It also contains any overwritten values from lower level dependencies.
This file contains the rules which the exposed values from this chart must align to.
It ensures that required fields are given to the installation as well as ensuring that they follow the required format/syntax.
This directory contains templates that are deployed from this Chart level.
It includes secrets, network policies, ingresses etc.

There are two site values used within the Application Chart repo,
- [site_values_template.yaml](../charts/__helmChartDockerImageName__/site_values_template.yaml) This site values is delivered
out with the chart and is used to expose customer site specific information for which
no default values can exist.
- [site values file](../csar-build/site-values.yaml) This site values file is used during the CSAR build process, to extract all the images from the chart template.


This chart serves as a template to develop other application chart and once it has been developed, the following command can be used to install that chart.

```
helm install --wait --timeout=720 ./charts/<developed chart name> -f sample-site-values.yaml
```

> **Note:** This chart is only for reference for other application developer to follow and should not be installed in any environment as is.
