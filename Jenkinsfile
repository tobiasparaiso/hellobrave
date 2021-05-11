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
        stage('Pre Setup') {
            steps {
                    sh 'curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/aws-iam-authenticator' 
                    sh 'chmod +x ./aws-iam-authenticator'                         
                    sh 'mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$PATH:$HOME/bin' 
                    sh "echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc"
                }
            }  
        stage('Provisioning AWS Infrastructure') {
            agent {
                docker { 
                    image 'hashicorp/terraform:0.14.0'
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
                    sh 'terraform output -state=$TERRAFORM_STATE_DIR/terraform.tfstate -raw kubectl_config > cluster.conf'
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
                    image 'dtzar/helm-kubectl'
                    args '-e KUBECONFIG=cluster.conf -i --network host --entrypoint='
                }
            }
            steps {
                dir("${env.WORKSPACE}/kubernetes") { 
                    sh 'kubectl apply -f k8s.yaml'
                }
            }
        }
    }
}