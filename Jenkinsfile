pipeline {
    agent any

    environment {
        REGISTRY = "ghcr.io"
        IMAGE_NAME = "chc3954/my-blog-with-rails"
        // Generate a short commit hash for the tag
        IMAGE_TAG = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
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

        stage('Update Manifest & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'ghcr-credentials', 
                                                  usernameVariable: 'GHCR_USER', 
                                                  passwordVariable: 'GHCR_TOKEN')]) {
                    script {
                        // Configure git
                        sh "git config user.email 'jenkins@hyunchul.me'"
                        sh "git config user.name 'Jenkins Bot'"
                        
                        // Update deployment.yaml with new image tag
                        // Using sed to replace the image tag for both containers (web and solid-queue)
                        sh "sed -i 's|image: ${REGISTRY}/${IMAGE_NAME}:.*|image: ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}|g' k8s/deployment.yaml"
                        
                        // Check if there are changes
                        def changed = sh(script: "git status --porcelain", returnStdout: true).trim()
                        if (changed) {
                            // Stage, commit and push
                            sh "git add k8s/deployment.yaml"
                            sh "git commit -m 'chore: update deployment image tag to ${IMAGE_TAG} [skip ci]'"
                            
                            // Set remote URL with credentials
                            // Assuming the repo URL is https://github.com/chc3954/my-blog-with-rails.git
                            sh "git remote set-url origin https://${GHCR_USER}:${GHCR_TOKEN}@github.com/chc3954/my-blog-with-rails.git"
                            sh "git push origin HEAD:main"
                        } else {
                            echo "No changes to deployment manifest."
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Successfully deployed version ${IMAGE_TAG}!"
        }
        failure {
            echo "Pipeline failed."
        }
    }
}
