pipeline {
    agent any
    tools {
        maven 'fresh-maven'
        //jdk 'jdk8'
    }
    stages {
        stage ('Initialize') {
            steps {
                sh '''
                    echo "PATH = ${PATH}"
                    echo "M2_HOME = ${M2_HOME}"
                '''
            }
        }
        stage('Maven Package') {
            steps {
                sh 'mvn package'
                sh '''
                    echo "Download dependencies to $HOME/.m2"
                    ls -lah
                '''
            }
        }
        stage('Artifacts Build') {
            steps {
                sh 'mvn install'
                sh '''
                    echo "After this, there will be change to generate Docker containers"
                    find . -name '*.jar'
                '''
            }
        }
        stage('Docker Build') {
            steps {
                sh 'mvn docker:build'
                sh '''
                    echo "After this, will need to push them to registry."
                    docker images
                '''
            }
        }
    }
}
