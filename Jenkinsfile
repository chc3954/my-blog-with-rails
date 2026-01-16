pipeline {
    agent any

    environment {
        REGISTRY = "ghcr.io"
        IMAGE_NAME = "chc3954/my-blog-with-rails"
        // Use timestamp for sortable tags. Prefix with 'v' to ensure it sorts AFTER hex git hashes (v > a)
        IMAGE_TAG = sh(script: 'echo v$(date +%Y%m%d%H%M%S)', returnStdout: true).trim()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Docker Build') {
            when {
                expression {
                    def commitMsg = sh(script: "git log -1 --pretty=%B", returnStdout: true).trim()
                    return !commitMsg.contains("jenkins:")
                }
            }
            steps {
                script {
                    echo "Building image with tag: ${IMAGE_TAG}"
                    sh "docker build -t ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Docker Push') {
            when {
                expression {
                    def commitMsg = sh(script: "git log -1 --pretty=%B", returnStdout: true).trim()
                    return !commitMsg.contains("jenkins:")
                }
            }
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

        stage('Update Manifest') {
            when {
                expression {
                    def commitMsg = sh(script: "git log -1 --pretty=%B", returnStdout: true).trim()
                    return !commitMsg.contains("jenkins:")
                }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'ghcr-credentials', 
                                                usernameVariable: 'GIT_USER', 
                                                passwordVariable: 'GIT_TOKEN')]) {
                    script {
                        sh """
                            git config user.email "jenkins@example.com"
                            git config user.name "Jenkins"
                            
                            # Update image tag in deployment.yaml
                            sed -i 's|image: ${REGISTRY}/${IMAGE_NAME}:.*|image: ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}|g' k8s/deployment.yaml
                            
                            # Check if there are changes
                            if git diff --quiet k8s/deployment.yaml; then
                                echo "No changes to deployment.yaml"
                            else
                                git add k8s/deployment.yaml
                                git commit -m "jenkins: update image tag to ${IMAGE_TAG}"
                                git push https://${GIT_USER}:${GIT_TOKEN}@github.com/chc3954/my-blog-with-rails.git HEAD:main
                            fi
                        """
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
