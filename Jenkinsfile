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
                        docker build -t "hadilotfy/iti-webapp:build-${BUILD_NUMBER}" .
                        docker push "hadilotfy/iti-webapp:build-${BUILD_NUMBER}"
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
                                mv Deployment_files/deploy.yml Deployment_files/deploy.yml.tmp
                                cat Deployment_files/deploy.yml.tmp | envsubst > Deployment_files/deploy.yml
                                rm -f Deployment_files/deploy.yml.tmp
                                kubectl apply -f Deployment_files
                            '''

                        }
                }

            }
        }

        
    }
}