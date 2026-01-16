pipeline {
    agent any

    environment {
        REGISTRY = "ghcr.io"
        IMAGE_NAME = "chc3954/my-blog-with-rails"
        // Use timestamp for sortable tags (required for ArgoCD Image Updater alphabetical strategy)
        IMAGE_TAG = sh(script: "date +%Y%m%d%H%M%S", returnStdout: true).trim()
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
                    echo "Building image with tag: ${IMAGE_TAG}"
                    sh "docker build -t ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'ghcr-credentials', 
                                                  usernameVariable: 'GHCR_USER', 
                                                  passwordVariable: 'GHCR_TOKEN')]) {
                    script {
                        sh "echo ${GHCR_TOKEN} | docker login ${REGISTRY} -u ${GHCR_USER} --password-stdin"
                        sh "docker push ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
                        sh "docker logout ${REGISTRY}"
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Successfully built and pushed version ${IMAGE_TAG}!"
        }
        failure {
            echo "Pipeline failed."
        }
    }
}
