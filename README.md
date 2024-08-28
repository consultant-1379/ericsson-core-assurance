# Ericsson Core Assurance

[TOC]

This repo contains the Integration Chart for Ericsson Core Assurance application and its associated files.
All the files inside the repo are for reference and must be adhered while creating a helm chart.

This is the directory structure of the repo. Below is a description of the contents of each of the upper level directories.

```
ericsson-core-assurance
├── bob
├── charts
│   └── eric-service-assurance
│       ├── Chart.yaml
│       ├── eric-product-info.yaml
│       ├── kubeVersion.yaml
│       ├── optionality.yaml
│       ├── site_values_template.yaml
│       ├── values.schema.json
│       ├── values.yaml
│       └── templates
│           ├── configmaps
│           ├── hooks
│           ├── ingresses
│           ├── mesh-resources
│           ├── network-policy
│           ├── role-bindings
│           ├── roles
│           ├── secrets
│           └── service-accounts
├── testsuite
│   └── helm-chart-validator
│       └── site_values_template.yaml
├── docs
│   ├── Chart-Hooks.md
│   ├── chassis-chart.md
│   ├── ConfigMap.md
│   ├── csar-build.md
│   ├── developer_guide.md
│   ├── eric-product-info.md
│   ├── Gateway.md
│   ├── Helpers.md
│   ├── Ingress-Controller.md
│   ├── maven-archtype.md
│   ├── Network-Policy.md
│   ├── optionality.md
│   ├── role.md
│   ├── role-binding.md
│   ├── Secret.md
│   ├── Service-Account.md
│   ├── service-mesh.md
│   ├── site_values.md
│   ├── test-suite.md
│   ├── Values_Schema.md
│   ├── Virtual-Service.md
│   └── images
│       ├── Ingress.png
│       ├── Istio-gateway-traffic.png
│       ├── maven-archetype-example.png
│       ├── maven-help.png
│       └── site_values.png
├── ci
│   ├── local_pipelin_env.txt
│   ├── precode.Jenkinsfile
│   ├── ruleset2.0.yaml
│   └── kubernetes_range_checkers
│       ├── deprek8ion.sh
│       ├── generate_helm_tempaltes_for_supported_k8s.sh
│       ├── kubeconform.sh
│       └── print_supported_k8s_version.sh
```

This directory contains the Integration Chart for Ericsson Core Assurance.
See the [Chart documentation](docs/chassis-chart.md) for more details

This directory contains all the documentation describing this repository.

This directory contains the tests created for the Integration chart.
See the [OSS Integration chart chassis docs](docs/test-suite.md) for more details.

The details regarding creating a maven archetype project can be found in the [archetype documentation](docs/maven-archtype.md).

Send questions via SUBZERO - [Subzero - General](https://teams.microsoft.com/l/team/19%3aU8EuRwhdzSfSiRKb9uVPYR9Zmx7wAqvBD5zOR2nSV4o1%40thread.tacv2/conversations?groupId=2f7ef799-f4d3-499c-863e-6e4c6d117380&tenantId=92e84ceb-fbfd-47ab-be52-080c6b87953f)
Create new issue on IDUN component and IDUN Team Name as SubZero: Story

We are an inner source project and welcome contributions. See our
[Contributing Guide](contribution.md) for details.

See in [Contributing Guide](contribution.md)

Create a new issue on Subzero component under IDUN project:

Report [Support/Bug](https://jira-oss.seli.wh.rnd.internal.ericsson.com/browse/IDUN-40095)

See in [Contributing Guide](contribution.md) for further details

Support is available on our Teams channel:

- Send questions via
  [Subzero - General](https://teams.microsoft.com/l/team/19%3aU8EuRwhdzSfSiRKb9uVPYR9Zmx7wAqvBD5zOR2nSV4o1%40thread.tacv2/conversations?groupId=2f7ef799-f4d3-499c-863e-6e4c6d117380&tenantId=92e84ceb-fbfd-47ab-be52-080c6b87953f)
  Microsoft Teams channel

