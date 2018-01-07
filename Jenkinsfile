// 
// https://github.com/jenkinsci/pipeline-model-definition-plugin/wiki/Syntax-Reference
// https://jenkins.io/doc/book/pipeline/syntax/#parallel
// https://jenkins.io/doc/book/pipeline/syntax/#post
pipeline {
    agent any
    environment {
        REPO = 'fjudith/wordpress'
        PRIVATE_REPO = "${PRIVATE_REGISTRY}/${REPO}"
        DOCKER_PRIVATE = credentials('docker-private-registry')
    }
    stages {
        stage ('Checkout') {
            steps {
                script {
                    COMMIT = "${GIT_COMMIT.substring(0,8)}"

                    if ("${BRANCH_NAME}" == "master"){
                        TAG   = "latest"
                        NGINX = "nginx"
                        FPM   = "fpm"
                        CLI   = "cli"
                    }
                    else {
                        TAG   = "${BRANCH_NAME}"
                        NGINX = "${BRANCH_NAME}-nginx"
                        FPM   = "${BRANCH_NAME}-php7.1-fpm"
                        CLI   = "${BRANCH_NAME}-cli"                      
                    }
                }
                sh 'printenv'
            }
        }
        stage ('Docker build Micro-Service') {
            parallel {
                stage ('Wodpress Nginx'){
                    agent { label 'docker'}
                    steps {
                        sh "docker build -f nginx/Dockerfile -t ${REPO}:${COMMIT}-nginx nginx/"
                    }
                    post {
                        success {
                            echo 'Tag for private registry'
                            sh "docker tag ${REPO}:${COMMIT}-nginx ${PRIVATE_REPO}:${NGINX}"
                        }
                    }
                }
                stage ('Wordpress PHP-FPM') {
                    agent { label 'docker'}
                    steps {
                        sh "docker build -f php7-fpm/Dockerfile -t ${REPO}:${COMMIT}-fpm php7-fpm/"
                    }
                    post {
                        success {
                            echo 'Tag for private registry'
                            sh "docker tag ${REPO}:${COMMIT}-fpm ${PRIVATE_REPO}:${FPM}"
                        }
                    }
                }
                stage ('Wordpress CLI') {
                    agent { label 'docker'}
                    steps {
                        sh "docker build -f cli/Dockerfile -t ${REPO}:${COMMIT}-cli cli/"
                    }
                    post {
                        success {
                            echo 'Tag for private registry'
                            sh "docker tag ${REPO}:${COMMIT}-cli ${PRIVATE_REPO}:${CLI}"
                        }
                    }
                }
            }
        }
        stage ('Run'){
            parallel {
                stage ('Micro-Services'){
                    agent { label 'docker'}
                    steps {
                        // Create Network
                        sh "docker network create wordpress-micro-${BUILD_NUMBER}"
                        // Start database
                        sh "docker run -d --name 'mariadb-${BUILD_NUMBER}' -e MYSQL_ROOT_PASSWORD=wordpress -e MYSQL_USER=wordpress -e MYSQL_PASSWORD=wordpress -e MYSQL_DATABASE=wordpress --network wordpress-micro-${BUILD_NUMBER} amd64/mariadb:10.0"
                        sleep 15
                        // Start Memcached
                        sh "docker run -d --name 'memcached-${BUILD_NUMBER}' --network wordpress-micro-${BUILD_NUMBER} memcached"
                        // Start application micro-services
                        sh "docker run -d --name 'fpm-${BUILD_NUMBER}' --link mariadb-${BUILD_NUMBER}:mariadb --link memcached-${BUILD_NUMBER}:memcached --network wordpress-micro-${BUILD_NUMBER} -v wordpress-micro-data:/var/www/html ${REPO}:${COMMIT}-fpm"
                        sh "docker run -d --name 'nginx-${BUILD_NUMBER}' --link fpm-${BUILD_NUMBER}:wordpress --link memcached-${BUILD_NUMBER}:memcached --network wordpress-micro-${BUILD_NUMBER} -v wordpress-micro-data:/var/www/html ${REPO}:${COMMIT}-nginx"
                        // Get container IDs
                        script {
                            DOCKER_FPM   = sh(script: "docker ps -qa -f ancestor=${REPO}:${COMMIT}-fpm", returnStdout: true).trim()
                            DOCKER_NGINX = sh(script: "docker ps -qa -f ancestor=${REPO}:${COMMIT}-nginx", returnStdout: true).trim()
                        }
                    }
                }
            }
        }
        stage ('Test'){
            parallel {
                stage ('Micro-Services'){
                    agent { label 'docker'}
                    steps {
                        sleep 20
                        sh "docker logs nginx-${BUILD_NUMBER}"
                        // External
                        sh "docker run --rm --network wordpress-micro-${BUILD_NUMBER} blitznote/debootstrap-amd64:17.04 bash -c 'curl -iL -X GET http://${DOCKER_NGINX}:80'"
                    }
                    post {
                        always {
                            echo 'Remove micro-services stack'

                            sh "docker rm -fv nginx-${BUILD_NUMBER}"
                            sh "docker rm -fv fpm-${BUILD_NUMBER}"
                            sh "docker rm -fv memcached-${BUILD_NUMBER}"
                            sh "docker rm -fv mariadb-${BUILD_NUMBER}"
                            sleep 10
                            sh "docker network rm wordpress-micro-${BUILD_NUMBER}"
                        }
                        success {
                            sh "docker login -u ${DOCKER_PRIVATE_USR} -p ${DOCKER_PRIVATE_PSW} ${PRIVATE_REGISTRY}"
                            sh "docker push ${PRIVATE_REPO}:${FPM}"
                            sh "docker push ${PRIVATE_REPO}:${NGINX}"
                            sh "docker push ${PRIVATE_REPO}:${CLI}"
                        }
                    }
                }
            }
        }
    }
    post {
        always {
            echo 'Run regardless of the completion status of the Pipeline run.'
        }
        changed {
            echo 'Only run if the current Pipeline run has a different status from the previously completed Pipeline.'
        }
        success {
            echo 'Only run if the current Pipeline has a "success" status, typically denoted in the web UI with a blue or green indication.'

        }
        unstable {
            echo 'Only run if the current Pipeline has an "unstable" status, usually caused by test failures, code violations, etc. Typically denoted in the web UI with a yellow indication.'
        }
        aborted {
            echo 'Only run if the current Pipeline has an "aborted" status, usually due to the Pipeline being manually aborted. Typically denoted in the web UI with a gray indication.'
        }
    }
}