pipeline {
    agent {
        label 'jenkins-slave'
    }
    parameters {
        string(name:'bname',defaultValue: "${BRANCH_NAME}",description: "holds the name of the current branch")
//        choice(name: 'bname', choices:['dev','test','preprod','release'])
    }
    stages {
        stage('build'){
            steps{
                echo "Build Stage"
                script{
                    if( params.bname== 'release'){
                        withCredentials([usernamePassword(credentialsId: 'hadi-dockerhub-creds', usernameVariable: 'USERNAME',passwordVariable: 'PASSWORD')]){
                            sh '''
                                docker login -u ${USERNAME} -p ${PASSWORD}
                                docker build -t hadilotfy/jenkins_lab2:build-${BUILD_NUMBER} .
                                docker push hadilotfy/jenkins_lab2:build-${BUILD_NUMBER}
                                echo ${BUILD_NUMBER} > ../build_num.t
                            '''
                        }
                    }
                    else {
                        echo "sorry, build only if branch: release  you chose branch: ${params.bname}"
                    }
                }
            }
        }
        stage('deploy'){
            steps{
                echo "Deploy Stage"
                script{
                    if (params.bname == 'dev' || params.bname=='test' || params.bname=='prod'){
                        withCredentials([file(credentialsId: 'hadi-minikube-kubeconfig', variable: 'KUBECONFIG_FILE')]){
                            sh '''#!/bin/bash
                                export BUILD_NUM=$(cat ../build_num.t)
                                re='^[0-9]+$'
                                if ! [[ $BUILD_NUM =~ $re ]] ; then echo "error: No BUILD_NUM, assume 0"; BUILD_NUM=0; fi
                                mv Deployment_files/deploy.yml Deployment_files/deploy.yml.tmp
                                cat Deployment_files/deploy.yml.tmp | envsubst > Deployment_files/deploy.yml
                                rm -f Deployment_files/deploy.yml.tmp
                            '''
                            sh """
                                echo "==============================="
                                echo "Branch Name: ${params.bname} "
                                kubectl create ns ${params.bname} --kubeconfig \${KUBECONFIG_FILE} || echo "ns already AlreadyExists"
                                kubectl apply -n ${params.bname} -f Deployment_files --kubeconfig \${KUBECONFIG_FILE}
                                                                                                  
                            """
                        }
                    }
                }
            }
        }
    }
}


