pipeline {
    agent any // Execute in an environment (node) that can run Docker commands

    environment {
        // GHCR configuration
        REGISTRY = "ghcr.io"
        IMAGE_NAME = "chc3954/my-blog-with-rails" // ghcr.io/username/repository-name
        IMAGE_TAG = "latest" 
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    // Build the Docker image
                    // For Rails 8, Dockerfile must exist in project root
                    sh "docker build -t ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Docker Push to GHCR') {
            steps {
                // Login using Jenkins credentials
                withCredentials([usernamePassword(credentialsId: 'ghcr-credentials', 
                                                  usernameVariable: 'GHCR_USER', 
                                                  passwordVariable: 'GHCR_TOKEN')]) {
                    script {
                        // 1. Login to GHCR
                        sh "echo ${GHCR_TOKEN} | docker login ${REGISTRY} -u ${GHCR_USER} --password-stdin"
                        
                        // 2. Push image
                        sh "docker push ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
                        
                        // 3. Logout for security (optional)
                        sh "docker logout ${REGISTRY}"
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Successfully built and pushed the image to GHCR!"
        }
        failure {
            echo "Pipeline failed. Please check the logs."
        }
    }
}
