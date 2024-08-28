#!/usr/bin/env groovy
def bob = "bob/bob -r ci/ruleset2.0.yaml"
@Library('oss-common-pipeline-lib@dVersion-2.0.0-hybrid') _   // Shared library from the OSS/com.ericsson.oss.ci/oss-common-ci-utils
def gerritReviewCommand = "ssh -p 29418 gerrit-gamma.gic.ericsson.se gerrit review \${GIT_COMMIT}"
def verifications = [
        // 'Helm-Lint'     : 0,
        // 'Design-Rules'  : 0,
        'Verified'      : -1,
]
pipeline {
    agent { label env.AGENT_LABEL }
    parameters {
        string(name: 'ARMDOCKER_USER_SECRET',
                defaultValue: 'cloudman-docker-auth-config',
                description: 'ARM Docker secret')
    }
    environment {
        SKIP_CHART_SCHEMA_VALIDATION = false
        HELM_REPO_CREDENTIALS = "${env.WORKSPACE}/repositories.yaml"
        KUBECONFORM_KINDS_TO_SKIP = "HTTPProxy,ServerCertificate,InternalCertificate,ClientCertificate,CertificateAuthority,adapter,attributemanifest,AuthorizationPolicy,CustomResourceDefinition,DestinationRule,EnvoyFilter,Gateway,handler,HTTPAPISpec,HTTPAPISpecBinding,instance,PeerAuthentication,QuotaSpec,QuotaSpecBinding,RbacConfig,RequestAuthentication,rule,ServiceEntry,ServiceRole,ServiceRoleBinding,Sidecar,Telemetry,template,VirtualService,WorkloadEntry,WorkloadGroup"
        HELM_REPO_CREDENTIALS_ID = "ossapps100_helm_repository_creds_file"
        HELM_REPOSITORY_NAME = "proj-eric-oss-drop-helm-local"
    }

    //#step 1 :package chart
    //#step 2: K8s checks
    //#step 3: helm testsuite (reusable image)
    //#step 4: design rules

    stages {
        stage('Initialize Workspace') {
            steps {
                sh 'git clean -xdff'
                sh 'git submodule sync'
                sh 'git submodule update --init --recursive'
            }
        }

        stage('Package Helm Charts') {
            steps {
                script {
                    withCredentials([file(credentialsId: env.HELM_REPO_CREDENTIALS_ID, variable: 'HELM_REPO_CREDENTIALS_FILE')]) {
                        sh "install -m 600 ${HELM_REPO_CREDENTIALS_FILE} ${env.HELM_REPO_CREDENTIALS}"
                        sh "${bob} helm-package-pcr"
                    }
                }
            }
        }

        stage('Kubernetes Range Compatibility Tests') {
            steps {
                script {
                    withCredentials([file(credentialsId: params.ARMDOCKER_USER_SECRET, variable: 'DOCKERCONFIG')]) {
                        sh "install -m 600 ${DOCKERCONFIG} ${HOME}/.docker/config.json"
                        sh "${bob} run-kubernetes-compatibility-tests:chmod-execute-support-kubernetes-versions"
                        sh "${bob} run-kubernetes-compatibility-tests:chmod-execute-generate-helm-templates"
                        sh "${bob} run-kubernetes-compatibility-tests:chmod-execute-kubeconform"
                        sh "${bob} run-kubernetes-compatibility-tests:chmod-execute-deprek8ion"
                        sh "${bob} run-kubernetes-compatibility-tests"
                    }
                }
            }
        }

        // stage('Run Helm Chart Testsuite'){
        //     steps {
        //         script {
        //             withCredentials([file(credentialsId: params.ARMDOCKER_USER_SECRET, variable: 'DOCKERCONFIG')]) {
        //                 sh "install -m 600 ${DOCKERCONFIG} ${HOME}/.docker/config.json"
        //                 sh "${bob} run-chart-testsuite"
        //             }
        //         }
        //     }
        //     post {
        //         always {
        //             sh "${bob} test-suite-report-and-clean"
        //             archiveArtifacts artifacts: 'chart-test-report.html', allowEmptyArchive: true
        //         }
        //     }
        // }

        stage('Design Rules Check') {
            steps {
                withCredentials([file(credentialsId: env.HELM_REPO_CREDENTIALS_ID, variable: 'HELM_REPO_CREDENTIALS_FILE')]) {
                    sh "install -m 600 ${HELM_REPO_CREDENTIALS_FILE} ${HELM_REPO_CREDENTIALS}"
                    sh "${bob} set-design-rule-parameters design-rule-checker"
                }
            }
            post {
                always {
                    archiveArtifacts 'design-rule-check-report.html'
                }
                success {
                    script {
                        verifications['Verified'] = +1
                    }
                }
                failure {
                    script {
                        verifications['Verified'] = -1
                    }
                }
            }
        }
    }
    post {
        always {
           archiveArtifacts allowEmptyArchive: true, artifacts: 'ci/*.Jenkinsfile'
           archiveArtifacts allowEmptyArchive: true, artifacts: 'ci/ruleset2.0.yaml'
        }
        success {
            script {
                verifications['Verified'] = +1
                def labelArgs = verifications
                        .collect { entry -> "--label ${entry.key}=${entry.value}" }
                        .join(' ')
                sh "${gerritReviewCommand} ${labelArgs}"
            }
        }
        failure {
            script {
                def labelArgs = verifications
                        .collect { entry -> "--label ${entry.key}=${entry.value}" }
                        .join(' ')
                sh "${gerritReviewCommand} ${labelArgs}"
            }
        }
    }
}
