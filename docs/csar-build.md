# CSAR Build Populated Site Values File

[TOC]

Each application repo will have a CSAR populated site values file in the root of the repo, i.e.
~/csar-build/site-values.yaml.

The [site values file](../csar-build/site-values.yaml) contains all the mandatory key/value
pairs that are required to perfrom a helm template against the application chart.
This site values file is used during the CSAR build process, to extract all the images from the
chart template. It does this by executing a "helm template", against the application chart and the
populated site values file. From the template generated the image can be retrieved.

All keys and values should be included in the site values file that are required to generate a full
template to ensure all images are captured.

The site values should be populated with dummy details so the helm template can execute without issue.


The entire csar build process is governed by [Spinnaker Flows](https://spinnaker.rnd.gic.ericsson.se/#/applications/common-e2e-cicd/executions?pipeline=oss-csar-build-flow) with the help of jenkins jobs.


The CSAR build is made up of a number of Jenkins file. The main tool that generates the CSAR is the
[am-package-manager](https://gerrit-gamma.gic.ericsson.se/plugins/gitiles/OSS/com.ericsson.orchestration.mgmt.packaging/am-package-manager/+/refs/heads/master).


The AM package manger takes in the Chart and the site values and uses these to perform a "[helm template](https://helm.sh/docs/helm/helm_template/)".

**Example Helm template:**
```
helm3 template eric-oss-ericsson-adaptation-0.1.0-554.tgz --values ./site-values-populated.yaml
```

When the template is generated the am-package-manager creates a list of all the images. The images
present in this list are pulled down from their respective repositories and are archived along with the
helm chart to create a CSAR package.


The application design area are responsible to ensure the csar build site-values in there repo will fetch all
the images from the chart when executing a "helm template" command.

To test the site values to ensure all the images are retrieved the following example can be followed.
```
> helm template <CHART FILE>.tgz --values csar-build/site-values.yaml > test.txt
> cat test.txt | grep image:
        image: armdocker.rnd.ericsson.se/proj-eric-oss-drop/eric-oss-data-catalog:1.0.15-1
        image: "armdocker.rnd.ericsson.se/proj-document-database-pg/data/eric-data-document-database-pg:5.6.0-61"
        image: armdocker.rnd.ericsson.se/proj-document-database-pg/data/eric-data-document-database-metrics:5.6.0-61
        image: armdocker.rnd.ericsson.se/proj-adp-eric-data-dc-zk-drop/eric-data-coordinator-zk:1.17.0-17
        image: armdocker.rnd.ericsson.se/proj-adp-message-bus-kf-drop/eric-data-message-bus-kf:1.20.0-23
        image: armdocker.rnd.ericsson.se/proj-adp-message-bus-kf-drop/eric-data-message-bus-kf:1.20.0-23
        image: "armdocker.rnd.ericsson.se/proj-orchestration-so/eric-oss-pf-readiness:1.1.1"
        image: "armdocker.rnd.ericsson.se/proj-orchestration-so/eric-oss-dmaap:1.0.0-53"
        image: "armdocker.rnd.ericsson.se/\
        image: "armdocker.rnd.ericsson.se/\
        image: "armdocker.rnd.ericsson.se/\
        image: armdocker.rnd.ericsson.se/proj-eric-oss-drop/eric-oss-helm-test:1.0.0-1
        image: "armdocker.rnd.ericsson.se/proj-document-database-pg/data/eric-data-document-database-kube-client:5.6.0-61"
        image: "armdocker.rnd.ericsson.se/proj-orchestration-so/eric-oss-dmaap:1.0.0-53"
```


> **Note**: It is very important that the designer must double-check the image list obtained from above commands against images that are required to install the chart.

The images that are not rendered using "helm template <chart name>" command will not be included in the CSAR package.


The csar site values file is used to render the image list from the chart, the images from this list are pulled from the docker registry to build CSAR package.