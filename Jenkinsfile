pipeline {
    agent {
        label 'jenkins-slave'
    }
    stages {
        stage("build"){
            steps{
                echo "Build Stage"                
            }
        }
        stage("dockerize"){
            steps{
                echo "Dockerization Stage"
                script{
                    withCredentials([usernamePassword(credentialsId: 'hadi-dockerhub-creds', usernameVariable: 'USERNAME',passwordVariable: 'PASSWORD')]){
                    sh '''
                        docker login -u ${USERNAME} -p ${PASSWORD}
                        docker build -t hadilotfy/ITI-FinalProject-WebApp:build-${BUILD_NUMBER} .
                        docker push hadilotfy/ITI-FinalProject-WebApp:build-${BUILD_NUMBER}
                        echo ${BUILD_NUMBER} > ../build_num.t
                    '''
                    }    
                }
            }
        }
        stage("deploy"){
            steps{
                echo "Deployment Stage"
                script{
                        withCredentials([file(credentialsId: 'eks-webapp-cluster-kubeconfig', variable: 'KUBECONFIG_FILE')]){
                            sh '''#!/bin/bash
                                export BUILD_NUM=$(cat ../build_num.t)
#                                re='^[0-9]+$'
#                                if ! [[ $BUILD_NUM =~ $re ]] ; then echo "error: No BUILD_NUM, assume 0"; BUILD_NUM=0; fi
                                mv Deployment_files/deploy.yml Deployment_files/deploy.yml.tmp
                                cat Deployment_files/deploy.yml.tmp | envsubst > Deployment_files/deploy.yml
                                rm -f Deployment_files/deploy.yml.tmp
                            '''
                            sh """
                                echo "==============================="
                                #kubectl apply -f Deployment_files --kubeconfig \${KUBECONFIG_FILE}
                                                                                                  
                            """
                        }
                }

            }
        }

        
    }
}


