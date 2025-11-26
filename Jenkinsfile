pipeline {
    agent any

    environment {
        DOCKERHUB_USER = "robbenselvaone"
        DOCKERHUB_CREDS = "dockerhub-creds"     // Jenkins credential ID
        EC2_KEY = "ec2-ssh-key"                 // Jenkins SSH key credential ID
        EC2_HOST = "ec2-13-201-130-150.ap-south-1.compute.amazonaws.com"
        EC2_USER = "ubuntu"
    }

    stages {

        stage('Check Branch') {
            steps {
                script {
                    if (!(env.BRANCH_NAME == "dev" || env.BRANCH_NAME == "main")) {
                        error("This pipeline only runs for dev or main branch!")
                    }

                    if (env.BRANCH_NAME == "dev")
                        env.REPO = "${DOCKERHUB_USER}/project2-dev"
                    else
                        env.REPO = "${DOCKERHUB_USER}/project2-production1"

                    env.TAG = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    env.IMAGE = "${env.REPO}:${env.TAG}"
                }
            }
        }

        stage('Build Image') {
            steps {
                sh """
                    chmod +x build.sh
                    ./build.sh ${IMAGE}
                """
            }
        }

        stage('Push Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CREDS}", usernameVariable: "USER", passwordVariable: "PASS")]) {
                    sh """
                        echo "$PASS" | docker login -u "$USER" --password-stdin
                        docker push ${IMAGE}
                    """
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: "${EC2_KEY}", keyFileVariable: 'SSH_KEY')]) {
                    sh """
                        scp -o StrictHostKeyChecking=no -i $SSH_KEY deploy.sh docker-compose.yml ${EC2_USER}@${EC2_HOST}:/tmp/
                        ssh -o StrictHostKeyChecking=no -i $SSH_KEY ${EC2_USER}@${EC2_HOST} "cd /tmp && chmod +x deploy.sh && ./deploy.sh ${IMAGE}"
                    """
                }
            }
        }
    }
}

