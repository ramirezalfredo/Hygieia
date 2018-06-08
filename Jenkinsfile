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
        stage('Maven Install') {
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
                //docker.withRegistry('https://537899582775.dkr.ecr.us-east-2.amazonaws.com', '387d5f7f-53d2-4b1a-8f4f-186d6ffb5374') 
                sh 'terraform/deploy.sh'
            }
        }
    }
}