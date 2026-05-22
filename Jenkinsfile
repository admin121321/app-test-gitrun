pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_IMAGE = 'sudiman19/laravel-app'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/admin121321/app-test-gitrun.git',
                    credentialsId: 'github_token'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'composer install --no-interaction --optimize-autoloader'
                sh 'npm install && npm run build'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'cp .env.testing .env'
                sh 'php artisan key:generate'
                sh 'php artisan migrate --env=testing --force'
                sh './vendor/bin/phpunit'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}")
                }
            }
        }

        stage('Push to Registry') {
            steps {
                script {
                    docker.withRegistry("https://${DOCKER_REGISTRY}", 'docker_hub_credentials') {
                        docker.image("${DOCKER_IMAGE}:${DOCKER_TAG}").push()
                        docker.image("${DOCKER_IMAGE}:${DOCKER_TAG}").push('latest')
                    }
                }
            }
        }

        stage('Deploy to Server') {
            steps {
                sshagent(['server_deploy_key']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ususbuntu@10.40.120.216 '
                            docker pull ${DOCKER_IMAGE}:${DOCKER_TAG}
                            cd /opt/laravel-app
                            docker-compose down
                            docker-compose up -d
                            docker exec laravel_app php artisan migrate --force
                        '
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline berhasil!'
        }
        failure {
            echo 'Pipeline gagal. Cek log untuk detail.'
        }
    }
}
