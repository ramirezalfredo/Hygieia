pipeline {
    agent any
    tools {
        maven 'fresh-maven'
        //jdk 'jdk8'
    }
    stages {
        // stage ('Initialize') {
        //     steps {
        //         sh '''
        //             echo "PATH = ${PATH}"
        //             echo "M2_HOME = ${M2_HOME}"
        //         '''
        //     }
        // }
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
                /*
                sh 'mvn clean package -pl api docker:build'
                sh 'mvn clean package -pl api-audit docker:build'
                sh 'mvn clean package -pl UI docker:build'
                sh 'mvn clean package -pl artifactory-artifact-collector docker:build'
                sh 'mvn clean package -pl bamboo-build-collector docker:build'
                sh 'mvn clean package -pl jenkins-build-collector docker:build'
                sh 'mvn clean package -pl aws-cloud-collector docker:build'
                sh 'mvn clean package -pl bitbucket-scm-collector docker:build'
                */

            }
        }
    }
}
