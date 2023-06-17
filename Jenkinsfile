pipeline {
    agent {
        label 'jenkins-slave'
    }
    stages {
        stage('build'){
            steps{
                echo "Build Stage"
                script{
                    if( ${BRANCH_NAME} == 'helm_release'){
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
                        echo "sorry, build only if branch: release  you chose branch: ${BRANCH_NAME}"
                    }
                }
            }
        }
        stage('deploy'){
            steps{
                echo "Deploy Stage"
                script{
                    if (${BRANCH_NAME} == 'helm_dev' || ${BRANCH_NAME}=='helm_test' || ${BRANCH_NAME}=='helm_preprod'){
                        withCredentials([file(credentialsId: 'hadi-minikube-kubeconfig', variable: 'KUBECONFIG_FILE')]){
                            sh '''#!/bin/bash
                                export BUILD_NUM=$(cat ../build_num.t)
                                re='^[0-9]+$'
                                if ! [[ $BUILD_NUM =~ $re ]] ; then echo "error: No BUILD_NUM, assume 0"; BUILD_NUM=0; fi
                            '''
                            sh """
                                echo "==============================="
                                echo "Branch Name: ${BRANCH_NAME} "
                                action='install'
                                if [ helm list  | cut -f 1 | grep ${BRANCH_NAME} ]; then
                                    action='upgrade'
                                fi
                                helm \$action "branch-${BRANCH_NAME}-release" ./app_chart \
                                              --set namespace=${BRANCH_NAME}\
                                              --set deploy.image.tag='build-\$BUILD_NUM'
                                              --kubeconfig \${KUBECONFIG_FILE}
                                                                                                  
                            """
                        }
                    }
                }
            }
        }
    }
}


