# Chart Hooks File

[TOC]

The document briefly covers the use of a Chart Hooks within the Helm Template.

Chart Hooks allow chart developers to intervene at certain points in a release's life cycle.

Hooks work like regular templates but have special annotations that cause Helm to utilize them differently.

> **Note:** To learn more about the use of Chart Hooks, please refer to the following [Helm Documentation](https://helm.sh/docs/topics/charts_hooks/)

Chart Hooks allows us to perform the following functionalities:

- Loading a ConfigMap or Secret during install before any other charts are loaded.

- Executing a Job to back up a database before installing a new chart, and then execute a second job after the upgrade in order to restore data.

- Running of a Job before deleting a release to gracefully take a service out of rotation before removing it.

When defining hooks for a certain point of a release's lifecycle (Such as Install lifecycle), they must either use the pre-install or post-install hooks from the list of Available Hooks below.

If a Hook for pre-install and post-install are defined, the lifecycle is altered through the following:

1. User runs the Install function on the chart.

2. The Helm library Install API is called.

3. Install of CRDs (Custom Resource Definitions) within the crds/ directory if any are present.

4. After some verification, the library render the chart's templates.

5. Library proceeds to execute the pre-install hooks (Loading resources into Kubernetes).

6. The Library sorts hooks by weight (0 by default), by resource kind and finally by name in ascending order.

7. The Library loads the hook with the lowest weight (See Section Hooks Weight).

8. The Library waits until the pre-install hook is in a "Ready" state and will then load the resulting resources into Kubernetes.

9. The Library will wait until all resources are in the "Ready" state, before run the post-install hook.

10. The Library waits until the post-install is in a "Ready" state.

11. The Library will return the release object to the client and the client will exit.

> **Note:** "Ready" state defined above depends on the resource that is declared in the hook. If the resource is a Job/Pod kind, Helm will wait until it successfully runs to completion.
>
> A Hook is a blocking operation, as the Helm Client will pause until the Job is run. Meaning if a hook fails, the release will fail.

```
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ template "eric-service-assurance.name" . }}-create-admin-user-hook
  labels:
    {{- include "eric-service-assurance.labels" .| nindent 4 }}
  annotations:
    {{- include "eric-service-assurance.helm-annotations" .| nindent 4 }}
    "helm.sh/hook": post-install, post-upgrade, post-rollback
    "helm.sh/hook-weight": "1"
    "helm.sh/hook-delete-policy": before-hook-creation, hook-succeeded
spec:
  template:
    metadata:
      labels:
        app: {{ template "eric-service-assurance.name" . }}
    spec:
      serviceAccountName: {{ template "eric-service-assurance.name" . }}-sa
      {{- if include "eric-service-assurance.keycloak-config.pullSecrets" . }}
      imagePullSecrets:
        - name: {{ template "eric-service-assurance.keycloak-config.pullSecrets" . }}
      {{- end }}
      {{- if .Values.topologySpreadConstraints }}
      topologySpreadConstraints: {{- toYaml .Values.topologySpreadConstraints | nindent 6}}
      {{- end }}
      {{- if .Values.tolerations }}
      tolerations: {{- toYaml .Values.tolerations | nindent 6 }}
      {{- end }}
      restartPolicy: Never
      containers:
        - name: keycloak-client
          image: {{ template "ericsson-service-assurance.keycloak-client-path" . }}
          imagePullPolicy: {{ .Values.imageCredentials.pullPolicy }}
          resources:
            requests:
              memory: {{ index .Values "eric-oss-create-admin-user-hook" "resources" "requests" "memory" }}
              cpu: {{ index .Values "eric-oss-create-admin-user-hook" "resources" "requests" "cpu" }}
            limits:
                memory: {{ index .Values "eric-oss-create-admin-user-hook" "resources" "limits" "memory" }}
                cpu: {{ index .Values "eric-oss-create-admin-user-hook" "resources" "limits" "cpu" }}
          env:
          - name: IAM_ADMIN_USER
            valueFrom:
              secretKeyRef:
                name: {{ .Values.global.iam.adminUser.secret | quote }}
                key: {{ .Values.global.iam.adminUser.userKey | quote }}
          - name: IAM_ADMIN_PASSWORD
            valueFrom:
              secretKeyRef:
                name: {{ .Values.global.iam.adminUser.secret | quote }}
                key: {{ .Values.global.iam.adminUser.passwordKey | quote }}
          - name: ADMIN_USER
            valueFrom:
              secretKeyRef:
                name: {{ .Values.global.iam.adminUser.secret | quote }}
                key: {{ .Values.global.iam.adminUser.userKey | quote }}
          - name: ADMIN_USER_PASSWORD
            valueFrom:
              secretKeyRef:
                name: {{ .Values.global.iam.adminUser.secret | quote }}
                key: {{ .Values.global.iam.adminUser.passwordKey | quote }}
          args:
          - "create"
          - "user"
          - "--keycloak_hostname={{ .Values.global.hosts.iam }}"
          - "--keycloak_user=$(IAM_ADMIN_USER)"
          - "--keycloak_password=$(IAM_ADMIN_PASSWORD)"
          - "--username=$(ADMIN_USER)"
          - "--password=$(ADMIN_USER_PASSWORD)"
          volumeMounts:
          - name: create-cacert-volume
            mountPath: /mnt/certs
          securityContext:
            privileged: false
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: false # keycloak client does write on the root file system
            runAsNonRoot: true
            runAsUser: 128474 # due to a limitation in the keycloak client image, it needs to be just this id
            capabilities:
              drop:
              - "all"
      {{- if .Values.terminationGracePeriodSeconds }}
      terminationGracePeriodSeconds:
        {{- .Values.terminationGracePeriodSeconds | nindent 8}}
      {{- end }}
      {{- include "eric-service-assurance.nodeSelector" .| indent 6 }}
      volumes:
      - name: create-cacert-volume
        secret:
          secretName: {{ .Values.global.iam.cacert.secretName }}
          items:
            - key: {{ .Values.global.iam.cacert.key }}
              path: {{ .Values.global.iam.cacert.filePath }}
```

The following hook above takes place after install, upgrade or a rollback occurs.

If there are any pre-existing hooks, the before-hook-creation deletion policy will delete the previous hooks before creating a new one.

Using the KeyCloak client, the system will run a Docker Image of a container in order to create an Admin User, given the environment variables that are passed through. The restart Policy of the container ensures that the container will never be restarted if an error occurs and will instead fail (And given the deletion policy -> (hook-failed) could be deleted).

Once the hook completes, the deletion Policy will take effect and will delete the hook.

Below is a list of available hooks that can be used within annotations:

| Parameter     | Description                                                                                            |
| ------------- | ------------------------------------------------------------------------------------------------------ |
| pre-install   | Executes after templates are rendered, but before any resources are created in Kubernetes.             |
| post-install  | Executes after all resources are loaded into Kubernetes.                                               |
| pre-delete    | Executes on a deletion request before any resources are deleted from Kubernetes.                       |
| post-delete   | Executes on a deletion request after all of the release's resources have been deleted.                 |
| pre-upgrade   | Executes on an upgrade request after templates are rendered, but before any resources are updated.     |
| post-upgrade  | Executes on an upgrade request after all resources have been upgraded.                                 |
| pre-rollback  | Executes on a rollback request after templates are rendered, but before any resources are rolled back. |
| post-rollback | Executes on a rollback request after all resources have been modified.                                 |
| test          | Executes when the Helm test subcommand is invoked.                                                     |

Defining a weight for a hook will help build a deterministic executing order from lowest to highest (Negative-Positive) number.

You can define a weight by adding the following:

```
annotations:
  "helm.sh/hook-weight": "5"
```

It is also possible to define policies that determine when to delete corresponding hook resources.

| Parameter            | Description                                                  |
| -------------------- | ------------------------------------------------------------ |
| before-hook-creation | Delete the previous resource before a new hook is launched.  |
| hook-succeeded       | Delete the resource after the hook is successfully executed. |
| hook-failed          | Delete the resource if the hook failed during execution.     |

If no hook deletion policy annotation is specified, the before-hook-creation policy is applied by default.

Given the example Hook above, below is the process of adding a hook that will sleep for 10 seconds when activated (post-install):

1. Firstly, we need to determine the Helm Annotations that are need to run the job.

- The Job should be run post-install, so we need to add a value of "post-install" to "helm.sh/hook"

- The hook weight given to the Job should be 1 as to give priority to the job, so we need to add "1" to "helm.sh/hook-weight".

- The Hook Deletion Policy should be enabled so that pre-existing hooks should be deleted before running the hooks and the hook should be deleted after a successful run.

In order to achieve the pre-requisites above, we need to add the following parameters to the Job:

```
"helm.sh/hook": post-install
"helm.sh/hook-weight": "1"
"helm.sh/hook-delete-policy": before-hook-creation, hook-succeeded
```

In order to complete the hooks, we must add the specification that is needed to run the container/Job:

- The specification will contain metadata (Name of the Application etc.)

- The specification will also denote the containers that need to be run, in our case we want to add a post-install-job that will use the alpine:3.3 image in order to pause the execution of the script for 10 seconds by default.

- With a restartPolicy set to "Never", as we don't want to restart the hook if it fails.

- In order to achieve the above we will add the following parameters.

```
spec:
  template:
    metadata:
      labels:
        app: {{ template "eric-service-assurance.name" . }}
    spec:
      restartPolicy: Never
      containers:
      - name: post-install-job
        image: "armdocker.rnd.ericsson.se/dockerhub-ericsson-remote/alpine:3.3"
        command: ["/bin/sleep","{{ default "10" .Values.sleepyTime }}"]
```

This would result in the following Post Install Hook Job being created:

```
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ template "eric-service-assurance.name" . }}-sleep
  labels:
    {{- include "ericsson-service-assurance" .| nindent 4 }}
  annotations:
    {{- include "eric-service-assurance.helm-annotations" .| nindent 4 }}
    "helm.sh/hook": post-install
    "helm.sh/hook-weight": "1"
    "helm.sh/hook-delete-policy": before-hook-creation, hook-succeeded
spec:
  template:
    metadata:
      labels:
        app: {{ template "eric-service-assurance.name" . }}
    spec:
      restartPolicy: Never
      containers:
        - name: post-install-job
          image: "armdocker.rnd.ericsson.se/dockerhub-ericsson-remote/alpine:3.3"
          command: ["/bin/sleep","{{ default 10 .Values.sleepyTime }}"]
```
