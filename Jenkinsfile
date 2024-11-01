pipeline {
    agent any

    environment{
      REGION = 'us-west-1'
      EKS_API = 'https://82AE94078DCC9C0CAA07A28A674B89CC.yl4.us-west-1.eks.amazonaws.com'
      EKS_CLUSTER_NAME = 'test-cluster'
      EKS_JENKINS_CREDENTIAL_ID = '97230b33-2ede-44f9-a0c6-5b16bcd9c5dc'
      ECR_PATH = '913524939383.dkr.ecr.us-west-1.amazonaws.com/test-ecr/'
      ECR_IMAGE = 'client'
      AWS_CREDENTIAL_ID = '97ea2ac7-5908-444b-9074-35e603a9e111'

    }
    stages {
        stage('Clone Repository'){
            checkout scm
        }
        stage('Docker Build'){
        docker.withRegistry("https://${ECR_PATH}", "ecr:${REGION}:${AWS_CREDENTIAL_ID}"){
            image = docker.build("${ECR_PATH}/${ECR_IMAGE}")
            }
        }
        stage('Push to ECR'){
            docker.withRegistry("https://{ECR_PATH}", "ecr:${REGION}:${AWS_CREDENTIAL_ID}"){
                image.push("v${env.BUILD_NUMBER}")
            }
        }
        stage('CleanUp Images'){
            sh"""
            docker rmi ${ECR_PATH}/${ECR_IMAGE}:v$BUILD_NUMBER
            docker rmi ${ECR_PATH}/${ECR_IMAGE}:latest
            """
        }
        stage('Deploy to k8s'){
        withKubeConfig([credentialsId: "{EKS_JENKINS_CREDENTIAL_ID}",
                        serverUrl: "${EKS_API}",
                        clusterName: "${EKS_CLUSTER_NAME}"]){
            sh "sed 's/IMAGE_VERSION/v${env.BUILD_ID}/g' service.yaml > output.yaml"
            sh "aws eks --region ${REGION} update-kubeconfig --name ${EKS_CLUSTER_NAME}"
            sh "kubectl apply -f output.yaml"
            sh "rm output.yaml"
             }
        }
}