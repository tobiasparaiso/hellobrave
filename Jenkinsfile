pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
        AWS_REGION = "${param_aws_region}"
        TERRAFORM_STATE_DIR = "${param_terraform_state_dir}"
        CONTAINER_REGISTRY = "${param_container_registry}"
    }
    stages {
        stage('Provisioning AWS Infrastructure') {
            agent {
                docker { 
                    image 'hashicorp/terraform:0.12.26'
                    args '-i --network host -v "$TERRAFORM_STATE_DIR":/backend --entrypoint='
                }
            }
            steps {
                dir(path: 'terraform/') { 
                    sh 'terraform init' 
                    sh 'terraform plan -var "aws_access_key_id=$AWS_ACCESS_KEY_ID" \
                        -var "aws_secret_access_key=$AWS_SECRET_ACCESS_KEY" \
                        -var "aws_region=$AWS_REGION"'                                        
                    sh 'terraform apply -auto-approve -var "aws_access_key_id=$AWS_ACCESS_KEY_ID" \
                        -var "aws_secret_access_key=$AWS_SECRET_ACCESS_KEY" \
                        -var "aws_region=$AWS_REGION"' 
                    sh 'terraform output -raw cluster_name > cluster.conf'
                }
            }
        }     
        stage("Build image") {
            steps {
                script {
                    myimage = docker.build("${CONTAINER_REGISTRY}/hellobrave:${env.BUILD_ID}")
                }
            }
        }
        stage("Push image") {
            steps {
                script {
                     docker.withRegistry('https://registry.hub.docker.com', 'dockerhub') {
                            myimage.push()
                            myimage.push("latest")
        stage('Deploy App') {
            agent {
                docker { 
                    image 'dtzar/helm-kubectl'
                    args '-e KUBECONFIG=admin.conf -i --network host --entrypoint='
                }
            }
            steps {
                dir("${env.WORKSPACE}/kubernetes") { 
                    sh 'kubectl apply -f k8s.yaml'
                }
            }
        }