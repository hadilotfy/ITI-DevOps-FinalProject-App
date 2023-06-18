def release_name = "branch-${BRANCH_NAME}-release"
pipeline {
    agent {
        label 'jenkins-slave'
    }
    stages {
        stage('build'){
            steps{
                echo "Build Stage"
                script{
                    if( "${BRANCH_NAME}" == 'helm-release'){
                        withCredentials([usernamePassword(credentialsId: 'hadi-dockerhub-creds', usernameVariable: 'USERNAME',passwordVariable: 'PASSWORD')]){
                            sh '''
                                docker login -u ${USERNAME} -p ${PASSWORD}
                                docker build -t hadilotfy/helm_lab:build-${BUILD_NUMBER} .
                                docker push hadilotfy/helm_lab:build-${BUILD_NUMBER}
                                echo ${BUILD_NUMBER} > ../build_num.t
                            '''
                        }
                    }
                    else {
                        echo "sorry, build only if branch: \'helm-release\', current branch: ${BRANCH_NAME}"
                    }
                }
            }
        }
        stage('deploy'){
            steps{
                echo "Deploy Stage"
                script{
                    if ("${BRANCH_NAME}" == 'helm-dev' || "${BRANCH_NAME}"=='helm-test' || "${BRANCH_NAME}"=='helm-preprod'){
                        withCredentials([file(credentialsId: 'hadi-minikube-kubeconfig', variable: 'KUBECONFIG_FILE')]){
                            sh """#!/bin/bash
                                export BUILD_NUM=\$(cat ../build_num.t)
                                re='^[0-9]+\$'
                                if ! [[ \$BUILD_NUM =~ \$re ]] ; then echo "No BUILD_NUM, assume 0"; BUILD_NUM=0; fi
                                echo "============= Branch  Name=== ${release_name}"
                                echo "============= Release Name=== ${BRANCH_NAME}"
                                echo "============= Image Build==== #\$BUILD_NUM"
                                action='install'
                                helm list --kubeconfig \${KUBECONFIG_FILE} | cut -f 1 | grep ${release_name} && action='upgrade'
                                helm \$action "${release_name}" ./app_chart \\
                                              --set deploy.image.tag="build-\$BUILD_NUM" \\
                                              --values 'branch_chartvals.yml' \\
                                              --kubeconfig \${KUBECONFIG_FILE}

                            """
                        }
                    }
                }
            }
        }
    }
}


