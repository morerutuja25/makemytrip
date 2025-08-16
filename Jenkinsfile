pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '3', artifactNumToKeepStr: '3'))
        // keep last 3 logs, others will be deleted
    }

    tools {
        maven 'mvn_3.9.9'
    }

    stages {
        stage('Code Compilation') {
            steps {
                echo 'Starting Code Compilation...'
                sh 'mvn clean compile'
                echo 'Code Compilation Completed Successfully!'
            }
        }

        stage('Code QA Execution') {
            steps {
                echo 'Running JUnit Test Cases.'
                sh 'mvn clean test'
                echo 'JUnit Test Cases Completed Successfully!!!'
            }
        }

        stage('Code Package') {
            steps {
                echo 'Creating WAR Artifact...'
                sh 'mvn package'
                echo 'WAR Artifact Created Successfully!'
            }
        }

        stage('Build & Tag Docker Image') {
            steps {
                echo 'Building Docker Image with Tags...'
                sh "docker build -t rutujam25/makemytrip-ms:latest -t makemytrip-ms:latest ."
                echo 'Docker Image Build Completed!'
            }
        }

        stage('Docker Image Scanning') {
            steps {
                echo 'Scanning Docker Image with Trivy...'
                sh 'trivy image ${DOCKER_IMAGE}:latest || echo "Scan Failed - Proceeding with Caution"'
                echo 'Docker Image Scanning Completed!'
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'dockerhubCred', variable: 'dockerhubCred')]) {
                        sh 'docker login docker.io -u satyam88 -p ${dockerhubCred}'
                        echo 'Pushing Docker Image to Docker Hub...'
                        sh 'docker push rutujam25/makemytrip-ms:latest'
                        echo 'Docker Image Pushed to Docker Hub Successfully!'
                    }
                }
            }
        }

        stage('Push Docker Image to Amazon ECR') {
            steps {
                script {
                    withDockerRegistry([credentialsId: 'ecr:ap-south-1:ecr-credentials', url: "https://533267238276.dkr.ecr.ap-south-1.amazonaws.com"]) {
                        echo 'Tagging and Pushing Docker Image to ECR...'
                        sh '''
                            docker images
                            docker tag makemytrip-ms:latest 533267238276.dkr.ecr.ap-south-1.amazonaws.com/makemytrip-ms:latest
                            docker push 533267238276.dkr.ecr.ap-south-1.amazonaws.com/makemytrip-ms:latest
                        '''
                        echo 'Docker Image Pushed to Amazon ECR Successfully!'
                    }
                }
            }
        }

        stage('Upload Docker Image to Nexus') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'nexus-credentials', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sh 'docker login http://43.205.196.227:8085/repository/makemytrip-ms/ -u admin -p ${PASSWORD}'
                        echo "Push Docker Image to Nexus : In Progress"
                        sh 'docker tag makemytrip-ms 43.205.196.227:8085/makemytrip-ms:latest'
                        sh 'docker push 43.205.196.227:8085/makemytrip-ms'
                        echo "Push Docker Image to Nexus : Completed"
                    }
                }
            }
        }

        stage('Cleanup Docker Images') {
            steps {
                echo 'Cleaning up local Docker images...'
                sh "docker rmi -f ${DOCKER_IMAGE}:latest || true"
                sh "docker rmi -f ${ECR_REPO}:latest || true"
                echo 'Local Docker images deleted successfully!'
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
