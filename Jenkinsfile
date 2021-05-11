pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
        AWS_REGION = "${param_aws_region}"
        TERRAFORM_STATE_DIR = "${param_terraform_state_dir}"
        CONTAINER_REGISTRY = "${param_container_registry}"
        APP_NAME = "${param_app_name}"
        APP_LABEL = "${param_app_label}"
    }
    stages {
        stage('Provisioning AWS Infrastructure') {
            agent {
                docker { 
                    image 'hashicorp/terraform:0.14.11'
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
                    sh 'terraform output -raw kubectl_config > ${WORKSPACE}/cluster.conf'
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
                        }
                }
            }
        }            
        stage('Deploy App') {
            agent {
                docker { 
                    image 'jshimko/kube-tools-aws:latest'
                    args '-i --network host -v "$WORKSPACE":/conf-workspace --entrypoint='
                }
            }
            steps {
                dir("${env.WORKSPACE}/kubernetes") { 
                    sh 'cat k8s.yaml | envsubst | kubectl --kubeconfig=/conf-workspace/cluster.conf apply -f -'
                }
            }
        }        
    }
}